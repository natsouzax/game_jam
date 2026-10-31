param([switch]$Recovery)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
$folder=Join-Path $projectRoot 'delivery\windows'
$testFolder=Join-Path $projectRoot 'delivery\tests'
$saveFolder=Join-Path $env:LOCALAPPDATA 'gameJam'
$filename=if($Recovery){'qa_recovery_result.json'}else{'qa_result.json'}
$resultPath=Join-Path $saveFolder $filename
if(Test-Path -LiteralPath $resultPath){Remove-Item -LiteralPath $resultPath}
$startedAt=Get-Date
$mode=if($Recovery){'--qa-recovery'}else{'--qa'}
$argsLine='-game "'+(Join-Path $folder 'data.win')+'" '+$mode
$process=Start-Process -FilePath (Join-Path $folder 'JUNTOS.exe') -ArgumentList $argsLine -WorkingDirectory $folder -WindowStyle Hidden -PassThru
if(!$process.WaitForExit(90000)){Stop-Process -Id $process.Id;throw 'QA timed out'}
if(!(Test-Path -LiteralPath $resultPath)){throw 'QA did not write a report'}
New-Item -ItemType Directory -Force $testFolder | Out-Null
Copy-Item -LiteralPath $resultPath -Destination (Join-Path $testFolder $filename) -Force
$report=Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
if(!$report.passed -or !$report.restarted){throw 'QA reported failure'}
Get-ChildItem -LiteralPath $saveFolder -Filter 'qa_*.png' | Where-Object LastWriteTime -ge $startedAt | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $testFolder $_.Name) -Force}
$report | Add-Member -NotePropertyName data_sha256 -NotePropertyValue ((Get-FileHash -LiteralPath (Join-Path $folder 'data.win') -Algorithm SHA256).Hash)
$report | Add-Member -NotePropertyName source_commit -NotePropertyValue ((git -C $projectRoot rev-parse HEAD).Trim())
$report | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $testFolder $filename) -Encoding UTF8
$report | ConvertTo-Json
