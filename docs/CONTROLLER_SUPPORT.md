# TOGETHER controls

The first connected controller controls Player 2 in co-op. In solo mode it controls whichever character was selected. Both keyboard layouts remain active while a controller is connected.

| Action | Player 1 keyboard | Player 2 keyboard | Controller |
|---|---|---|---|
| Move | A / D | Left / Right | Left stick / D-pad |
| Jump | W | Up | A / Cross |
| Build or break | E | Enter | X / Square |
| Charge dash | Q | Right Shift | B / Circle |
| Pause | Esc or P | Esc or P | Start / Options |

In menus, use the stick/D-pad to navigate, A to confirm, B to go back, and Start to resume from pause. On a built block, pressing the build action twice within half a second breaks it.

The code scans Windows XInput slots 0-3 and DirectInput slots 4-11. GameMaker's controller constants may vary on some generic DirectInput devices; test the actual controller before delivery. The 2026-11-01 automated Runner reported no connected controller (`gamepad_slot=-1`). Compilation, startup, keyboard regression, revive, and block interaction checks passed; physical controller input remains unverified.
