# TOGETHER

TOGETHER is a local co-op platform game for two people on one keyboard. Solo play lets you choose either character. Falling materials become blocks for climbing the shared tower. The opening and ending tell the story through images.

## Play

Extract the ZIP and open `windows/Play.cmd` or `windows/TOGETHER.exe`. Keep `data.win` beside the executable. Windows 64-bit / DirectX 11.

At the title screen, choose the one-person or two-person card with A/D or Left/Right, then press E or Enter. In solo mode, choose a character the same way. Press S or Down to go back. The framed gear at the lower right opens audio settings: W/S selects music or volume, A/D changes it, and E returns. E or Enter skips the opening after one second.

| Action | Solo or co-op P1 | Co-op P2 |
|---|---|---|
| Move / face | A / D | Left / Right |
| Jump | W | Up |
| Place a block | E | Enter |
| Restart after the ending | W or Up | W or Up |

Touch falling materials to collect them. Each player holds their own materials; placing a block costs one. The block appears ahead of the character. Jump on blocks and checkpoint platforms to climb. In co-op, both players must land at the top; in solo, only the chosen character does. After a fall or enemy hit, the affected character returns to a checkpoint and blocks built in that section disappear. Materials still held are kept.

## Release

The submission includes a Windows build and LDMT Plan/Final workbooks. The original workbook and formulas were preserved. All in-game words are limited to the title; controls belong in this external guide. Music and sound can be adjusted from the gear icon. No upload or publication has been performed.

The game and art were developed during the jam. Some supplied and generated art uses AI; see `ART_AND_SOURCES.md` for details. Automated Runner tests cover the main flow; a two-person keyboard playtest and a check on another PC remain useful before submission.
