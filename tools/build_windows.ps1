$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimePath = Join-Path $env:ProgramData 'GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$igorPath = Join-Path $runtimePath 'bin\igor\windows\x64\Igor.exe'
$stagePath = Join-Path $projectRoot 'delivery\windows'
$testPath = Join-Path $projectRoot 'delivery\tests'
New-Item -ItemType Directory -Force $stagePath,$testPath | Out-Null
$startedAt = Get-Date
& $igorPath "--project=$projectRoot\gameJam.yyp" "--rp=$runtimePath" "--user=$env:APPDATA\GameMakerStudio2-LTS2026\unknownUser_unknownUserID" "--cache=$env:TEMP\gamejam-igor-cache" "--temp=$env:TEMP\gamejam-igor-temp" "--of=$stagePath\gameJam.win" windows Compile 2>&1 | Tee-Object -FilePath (Join-Path $testPath 'compile.log')
if ($LASTEXITCODE -ne 0) { throw 'GameMaker compilation failed' }
$candidates = @((Join-Path $stagePath 'gameJam.win'),(Join-Path $env:TEMP 'gameJam.win'))
$compiledFile = $candidates | Where-Object { (Test-Path -LiteralPath $_) -and (Get-Item -LiteralPath $_).LastWriteTime -ge $startedAt.AddSeconds(-1) } | Select-Object -First 1
if (!$compiledFile) { throw 'Fresh compiled gameJam.win was not found' }
Copy-Item -LiteralPath $compiledFile -Destination (Join-Path $stagePath 'data.win') -Force
$engineSource = Join-Path $projectRoot 'build\gameJam.exe'
if (!(Test-Path -LiteralPath $engineSource)) { $engineSource = Join-Path $runtimePath 'windows\x64\Runner.exe' }
$engineDestination = Join-Path $stagePath 'TOGETHER.exe'
if (!(Test-Path -LiteralPath $engineDestination) -or (Get-FileHash -LiteralPath $engineSource).Hash -ne (Get-FileHash -LiteralPath $engineDestination).Hash) {
    Copy-Item -LiteralPath $engineSource -Destination $engineDestination -Force
}
Copy-Item -LiteralPath (Join-Path $projectRoot 'build\options.ini') -Destination (Join-Path $stagePath 'options.ini') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'delivery\README.md') -Destination (Join-Path $stagePath 'README.md') -Force
@('@echo off', 'cd /d "%~dp0"', 'start "" "%~dp0TOGETHER.exe" -game "%~dp0data.win"') | Set-Content -LiteralPath (Join-Path $stagePath 'Play.cmd') -Encoding ASCII
if (Test-Path -LiteralPath (Join-Path $stagePath 'gameJam.win')) { Remove-Item -LiteralPath (Join-Path $stagePath 'gameJam.win') }
Get-FileHash -LiteralPath (Join-Path $stagePath 'data.win'),(Join-Path $stagePath 'TOGETHER.exe') -Algorithm SHA256 | Format-Table -AutoSize
