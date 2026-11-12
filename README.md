
<div align="center">

# TOGETHER

### A ruined world. A tower to build. A journey to share.

**Build your way up. Survive the chaos. Reach the top together.**

A cooperative platformer created during a game jam, where teamwork, creativity, and survival are the keys to reaching the top.

**Play solo or with a friend — up to two controllers, with keyboard support.**

![GameMaker](https://img.shields.io/badge/Made_with-GameMaker-000000?style=flat-square&logo=gamemaker)
![Windows](https://img.shields.io/badge/Platform-Windows_64--bit-0078D6?style=flat-square)
![Players](https://img.shields.io/badge/Players-1--2-28a745?style=flat-square)
![Input](https://img.shields.io/badge/Input-Controllers_%7C_Keyboard-8b5cf6?style=flat-square)
![Status](https://img.shields.io/badge/Status-Playable_Release-e8a838?style=flat-square)

<br>

[![Download for Windows](https://img.shields.io/badge/DOWNLOAD_FOR_WINDOWS-Together__final.exe-28a745?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/natsouzax/game_jam/releases/latest/download/Together_final.exe)

[How to Play](#how-to-play) · [Controls](#controls) · [Development](#for-developers) · [Credits](#credits)

</div>

---

## Screenshots

<div align="center">

### Main Menu

![Together — Main Menu](docs/images/together-menu.png)

### Gameplay

![Together — Gameplay](docs/images/together-gameplay.png)

*Build, climb, and survive together.*

</div>

---

## The Game

**Together** is a cooperative platformer set in a ruined world where the only way forward is up.

Collect falling materials, construct platforms, avoid dangerous obstacles, and climb an enormous tower.

Play alone or join forces with a friend in local two-player co-op. Every block matters, every jump counts, and reaching the top requires determination.

In cooperative mode, **both players must reach the destination** to complete the journey.

### Core Features

- **Build your own path** — Collect materials and spend them to create blocks in the direction your character is facing.
- **Play together** — Experience local co-op with two players sharing the same screen.
- **Survive the climb** — Dodge meteors, defeat enemies, and overcome environmental hazards.
- **Use checkpoints** — Find green checkpoint platforms to secure your progress.
- **Choose your playstyle** — Play with up to two controllers or use keyboard controls.
- **Discover the story** — Experience an opening sequence that introduces the ruined world and your mission.

---

## Download & Play

<div align="center">

### Ready to climb?

**Download the Windows executable and start playing.**

### [Download Together_final.exe](https://github.com/natsouzax/game_jam/releases/latest/download/Together_final.exe)

[View All Releases](https://github.com/natsouzax/game_jam/releases)

</div>

### Installation

1. Download `Together_final.exe` from the link above.
2. Open the executable on your Windows computer.
3. Connect up to two controllers, or use your keyboard.
4. Choose your game mode and start playing!

**System requirements:**

| Component | Requirement |
|---|---|
| Operating System | Windows 64-bit |
| Graphics | DirectX 11 support |
| Input | Keyboard or up to 2 controllers |
| Game Engine | GameMaker |
| Multiplayer | Local co-op |

> GameMaker and the source code are not required to play the downloadable version.

---

## How to Play

### 1. Choose Your Game Mode

From the main menu, select solo or cooperative mode.

In solo mode, choose your character and confirm your selection again to begin.

### 2. Collect Materials

Materials fall throughout the level. Touch them to collect them.

Each player has their own material inventory.

### 3. Build Your Path

Use your collected materials to place blocks in front of your character.

Each block costs one material. Plan your path carefully and build toward the top.

### 4. Avoid Danger

The tower is full of threats:

- Enemies that can be defeated by jumping on them.
- Falling meteors capable of destroying your constructions.
- Dangerous gaps and obstacles that require precise movement.

Look for green platforms that act as checkpoints.

### 5. Reach the Top

Keep climbing until you reach the final area.

In cooperative mode, both active players must reach the destination.

**Together, the journey is the challenge.**

---

## Controls

Together was designed with controller-based gameplay in mind.

The game supports **up to two controllers simultaneously** for local multiplayer. Keyboard controls are also available for both players.

### Controller — Xbox & PlayStation

| Action | Xbox Controller | PlayStation Controller |
|---|---|---|
| Move | Left Stick / D-Pad | Left Stick / D-Pad |
| Jump | A | ✕ Cross |
| Build / Break | X | □ Square |
| Charge Dash | B | ○ Circle |

**Breaking blocks:** Stand on a previously built block and press the build button twice quickly.

### Keyboard

| Action | Player 1 | Player 2 |
|---|---|---|
| Move Left | A | ← |
| Move Right | D | → |
| Jump | W | ↑ |
| Build / Break | E | Enter |
| Charge Dash | Q | Right Shift |
| Pause | Esc / P | Esc / P |
| Toggle Audio | M | M |
| Toggle Fullscreen | F11 | F11 |

### Menu & Shortcuts

| Action | Key |
|---|---|
| Navigate Menu | W / S |
| Confirm Selection | E |
| Exit Game | Hold Esc for 3 seconds |
| Toggle Fullscreen | F11 |
| Toggle Audio | M |

---

## For Developers

Together was developed using **GameMaker** and **GameMaker Language (GML)**.

The complete project source code is available in this repository.

### Running the Source Project

1. Clone the repository:

   ```bash
   git clone https://github.com/natsouzax/game_jam.git
   ```

2. Open GameMaker.
3. Import or open `gameJam.yyp`.
4. Explore the project or run it directly from the editor.

### Project Structure

| Directory | Contents |
|---|---|
| `objects/` | Game objects and event logic |
| `scripts/` | Gameplay systems, controls, presentation, and testing |
| `rooms/` | Game levels and rooms |
| `sprites/` | Characters, objects, and visual assets |
| `sounds/` | Music and sound effects |
| `shaders/` | Rendering and visual effects |
| `art/` | Art references and production notes |
| `docs/` | Technical documentation and testing notes |
| `delivery/` | Earlier previews and jam delivery material |
| `tools/` | Development and production utilities |

### Release Information

The latest playable Windows release is distributed as:

**`Together_final.exe`**

Older builds and testing artifacts may still exist in the repository for development and historical reference.

The existing Windows packaging workflow targets an older preview located in `delivery/preview_opening_combat/`. It does not package the current final executable.

For the latest playable version, use the [official releases page](https://github.com/natsouzax/game_jam/releases).

---

## Credits

**Together** was created during a game jam by:

- Natan
- Guilherme
- Luiz
- Emmanuel
- Vanessa
- Vitally

### Art, Audio & Production

Some artwork and opening-video imagery were generated with the assistance of AI.

Scene narration uses synthesized speech, while music and sound effects were generated through scripts.

Additional information about the creative process and asset sources is available in the [Art & Source Notes](delivery/ART_AND_SOURCES.md).

---

## Feedback & Bug Reports

Together is a playable game jam release.

Technical test reports included in this repository may refer to earlier development builds.

Found a bug or have a suggestion?

[Open an Issue](https://github.com/natsouzax/game_jam/issues) and include:

- A description of the problem.
- Steps to reproduce it.
- Your Windows version.
- Whether you were using a keyboard or controller.

Feedback is always welcome!

---

<div align="center">

## Every journey is better together.

**Build a path. Bring someone with you.**

[![Play Together](https://img.shields.io/badge/PLAY_TOGETHER-DOWNLOAD_NOW-28a745?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/natsouzax/game_jam/releases/latest/download/Together_final.exe)

*Made with GameMaker.*

</div>
