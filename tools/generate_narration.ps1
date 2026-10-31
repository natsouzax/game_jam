param([int]$Rate = -1)
# Renders the English cutscene narration with the offline Windows voice and registers each line as a GameMaker sound.
# To use a better voice, replace sounds\narr_NN\narr_NN.wav with a 22050 Hz mono 16-bit file of the same line and update duration in the .yy.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$lines = @(
    'A god came to see the ruins.',
    'He could show them a better world. But he would not build it for them.',
    'So they began, one stone at a time.',
    'And the seedling was finally free to grow.',
    'The game was over. The screen went dark.',
    'They looked at one another.',
    'And they understood: nobody was coming to save them.',
    'If the world was going to change, it would have to be them.',
    'One began by cleaning the street in front of home.',
    'One carried light to a neighbour who was alone.',
    'One planted seeds where there was only bare earth.',
    'One watered the flowers no one else remembered.',
    'No one came to save the world. They did.',
    'Small acts, one person at a time. Together.'
)
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Rate = $Rate
$format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(22050, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$yyp = Join-Path $projectRoot 'gameJam.yyp'
$yypText = [System.IO.File]::ReadAllText($yyp)
$report = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
    $name = 'narr_{0:D2}' -f ($i + 1)
    $dir = Join-Path $projectRoot "sounds\$name"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $wav = Join-Path $dir "$name.wav"
    $synth.SetOutputToWaveFile($wav, $format)
    $synth.Speak($lines[$i])
    $synth.SetOutputToNull()
    $seconds = ((Get-Item $wav).Length - 44) / (22050 * 2)
    $dur = $seconds.ToString('0.000000', [System.Globalization.CultureInfo]::InvariantCulture)
    $yy = @"
{
  "`$GMSound":"v2",
  "%Name":"$name",
  "audioGroupId":{
    "name":"audiogroup_default",
    "path":"audiogroups/audiogroup_default",
  },
  "bitDepth":1,
  "channelFormat":0,
  "compression":0,
  "compressionQuality":4,
  "conversionMode":0,
  "duration":$dur,
  "exportDir":"",
  "name":"$name",
  "parent":{
    "name":"audio",
    "path":"folders/audio.yy",
  },
  "preload":true,
  "resourceType":"GMSound",
  "resourceVersion":"2.0",
  "sampleRate":22050,
  "soundFile":"$name.wav",
  "volume":1.0,
}
"@
    [System.IO.File]::WriteAllText((Join-Path $dir "$name.yy"), $yy)
    $entry = '{"id":{"name":"' + $name + '","path":"sounds/' + $name + '/' + $name + '.yy",},},'
    if ($yypText -notmatch [regex]::Escape('"name":"' + $name + '"')) {
        $anchor = '{"id":{"name":"mus_ending","path":"sounds/mus_ending/mus_ending.yy",},},'
        if (-not $yypText.Contains($anchor)) { throw 'mus_ending anchor not found in gameJam.yyp' }
        $yypText = $yypText.Replace($anchor, $anchor + "`r`n    " + $entry)
    }
    $report += [pscustomobject]@{ name = $name; seconds = [math]::Round($seconds, 2); frames = [math]::Ceiling($seconds * 60); text = $lines[$i] }
}
[System.IO.File]::WriteAllText($yyp, $yypText)
$report | Format-Table -AutoSize -Wrap
