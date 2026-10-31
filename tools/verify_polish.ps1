param([string]$ProjectRoot=(Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
$runtimePath=Join-Path $env:ProgramData 'GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$checkPath=Join-Path $env:TEMP ('gamejam-polish-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $checkPath | Out-Null
& (Join-Path $runtimePath 'bin\igor\windows\x64\Igor.exe') "--project=$ProjectRoot\gameJam.yyp" "--rp=$runtimePath" "--user=$env:APPDATA\GameMakerStudio2-LTS2026\unknownUser_unknownUserID" "--cache=$checkPath\cache" "--temp=$checkPath\temp" "--of=$checkPath\gameJam.win" windows Compile 2>&1 | Tee-Object -FilePath (Join-Path $checkPath 'compile.log') | Select-Object -Last 8
if($LASTEXITCODE -ne 0){throw 'Compilation failed'}
$originalLocalData=$env:LOCALAPPDATA
try {
    $env:LOCALAPPDATA=Join-Path $checkPath 'local'
    New-Item -ItemType Directory -Force $env:LOCALAPPDATA | Out-Null
    $process=Start-Process -FilePath (Join-Path $runtimePath 'windows\x64\Runner.exe') -ArgumentList @('-game',('"'+(Join-Path $checkPath 'gameJam.win')+'"'),'--qa-regression') -WorkingDirectory $checkPath -WindowStyle Hidden -RedirectStandardOutput (Join-Path $checkPath 'runtime.log') -RedirectStandardError (Join-Path $checkPath 'runtime-error.log') -PassThru
    if(!$process.WaitForExit(45000)){Stop-Process -Id $process.Id;throw 'Regression timed out'}
    $reportPath=Get-ChildItem -LiteralPath $checkPath -Recurse -Filter 'qa_regression_result.json' | Select-Object -First 1
    if(!$reportPath){throw 'No runtime regression report'}
    $report=Get-Content -LiteralPath $reportPath.FullName -Raw | ConvertFrom-Json
    if(!$report.passed){$report | ConvertTo-Json;throw 'Regression failed'}
    $testPath=Join-Path $ProjectRoot 'delivery\tests\polish'
    New-Item -ItemType Directory -Force $testPath | Out-Null
    Get-ChildItem -LiteralPath $reportPath.DirectoryName -Filter 'qa_regression*' | Copy-Item -Destination $testPath
    $report | ConvertTo-Json
    Write-Output "Evidence: $testPath"
    Write-Output "Logs and compiled game: $checkPath"
} finally {$env:LOCALAPPDATA=$originalLocalData}
