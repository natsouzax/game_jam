# Together: enemy and block interaction contract

Status: implemented in the local preview. Focused Runner checks passed on 2026-11-01; the complete automated climb replay and human playtest remain open.

## Build and break with one action

- P1 uses E; P2 uses Enter. The current facing direction determines the target cell.
- An empty valid cell builds one block and spends one material.
- If the cell contains a player-built block, the first press marks it with a visible crack. A second press by either player on that same cell within 0.5 seconds removes it. No material is spent on either press.
- The mark belongs to the block rather than to a player, so the mechanic is cooperative. If the second press is late or targets a different block, it starts a new mark.
- Fixed ground and checkpoints cannot be broken. Manual demolition refunds one material to the second player to allow correcting a misplaced block. Meteors do not refund material.
- A player standing on a broken block falls normally and may recover at the checkpoint; there is no teleport.

## Enemies and hazards

- Keep the existing small enemy types as the visual language. A flying chaser is the first mobile threat that can follow the players vertically. It selects the nearest living active player, approaches at a capped speed, and can be defeated by the existing stomp or P1 dash.
- Defeating an enemy awards exactly one material directly to the player who dealt the final blow. Partial damage and automatic enemy removal do not award material. This applies to stomps and P1 dash kills.
- Existing spawn director may add enemies as altitude increases, but the number of active enemies stays capped and new enemies must appear away from both players.
- Above the first climb segment, a meteor enters from above the camera with a visible warning. Collision damages a player once. On impact with a player-built block, the meteor destroys only that block and disappears. It never destroys ground or checkpoints.
- All hazards pause outside gameplay, stop at victory/game over, and honor the player invulnerability window after damage.

## Observable checks

1. Each player builds one block. One action on an occupied cell cracks it; a second action within 0.5 seconds removes it and returns one material. One action alone does not remove it.
2. Ground and checkpoints remain after two actions and meteor impact.
3. A flying chaser gains height with a climbing player, can hit once, and can be defeated.
   A kill adds one material to the killer's inventory; a nonlethal hit adds none.
4. Additional enemies appear with altitude without spawning on the players or exceeding the cap.
5. A meteor becomes visible before impact, breaks a built block, and does not freeze the game or crash when no block is hit.
6. Normal and recovery QA replays still reach victory and restart.

The focused Runner report `qa_block_interaction_result.json` passed all seven checks: build, mark, break, checkpoint protection, meteor impact, kill reward, and vertical chase. `qa_regression_result.json` also passed the short movement, dash, and menu checks. The older complete climb replay has not passed with the new forward block placement, so it is not evidence for this version.
