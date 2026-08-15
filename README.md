# Pascal Qwirkle

A console implementation of [Qwirkle](https://en.wikipedia.org/wiki/Qwirkle), the tile-laying board game, written in Object Pascal (Free Pascal). Two players place tiles that share a color or a shape to build lines on the board and score points — no external graphics library involved, everything renders as colored text in the terminal.

## Features

- Full Qwirkle placement and scoring rules (lines, cross-lines, and the 6-tile "Qwirkle" bonus)
- 2-player and 4-player local hot-seat modes
- Player vs. AI mode
- AI vs. AI exhibition mode
- A simple brute-force AI that tries every ordering of its hand to find the highest-scoring turn
- Colored terminal board and hand display via the `crt` unit

## Project layout

The game is split into small units instead of one large file:

| File | Responsibility |
| --- | --- |
| `Qwirkle.pas` | Program entry point and top-level menu |
| `QwirkleTypes.pas` | Shared types (tiles, board, hand, player, coordinates) |
| `QwirkleDeck.pas` | Draw pile creation, drawing, and exchanging tiles |
| `QwirkleBoard.pas` | Placement rules, turn scoring, and playability checks |
| `QwirkleDisplay.pas` | Console rendering of the board, hand, and scores |
| `QwirkleAI.pas` | Computer player move search |
| `QwirkleGame.pas` | Turn flow and the four game modes |

## Requirements

- [Free Pascal](https://www.freepascal.org/) (`fpc`), which ships the `crt` unit used for colored console output. No graphics library or other dependency is required.

## Building and running

```bash
fpc Qwirkle.pas
./Qwirkle      # Qwirkle.exe on Windows
```

`fpc` automatically picks up the other units (`QwirkleTypes.pas`, `QwirkleDeck.pas`, etc.) as long as they stay in the same directory as `Qwirkle.pas`.

## How to play

Launch the game and choose a mode from the menu, then follow the on-screen prompts (in French) to name your players and take turns. On your turn you can:

- **J**ouer — place one or more tiles from your hand onto the board
- **E**changer — swap tiles from your hand back into the draw pile
- **P**asser — pass your turn

Tiles are placed by board coordinates, shown as the `X`/`Y` axes framing the printed grid.

## Contributing

Issues and pull requests are welcome.

## License

MIT — see [LICENSE](LICENSE).
