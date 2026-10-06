# graphx_crisplib

A tiny immediate-mode game runtime for [GraphX 2](https://github.com/roipeker/graphx2), inspired by ABA Games' [crisp-game-lib](https://github.com/abagames/crisp-game-lib).

The goal is deliberately small game code: one `frame()` callback, a fixed logical stage, immediate drawing/collision calls, deterministic random helpers, and atlas-backed pixel characters/sprites.

```dart
final class MyGame extends CrispGame {
  @override
  final config = const CrispGameConfig(
    id: 'my_game',
    title: 'MY GAME',
    description: '[TAP] PLAY',
    seed: 1,
  );

  @override
  void frame(CrispContext g) {
    if (g.tick == 0) {
      // initialize game state
    }

    g.color(CrispColor.black);
    g.box(50, 50, 6);
  }
}
```

## Design constraints

- `char()` preserves the Crisp 6x6 visual and collision cell with no implicit padding.
- `SpriteClip` frames may use arbitrary pixel dimensions.
- `sprite()` uses the current frame bounds as its default collision area; custom hitboxes are opt-in.
- The logical stage is clipped by default.
- The runtime stays immediate-mode and intentionally avoids ECS/component boilerplate.

## Dependency

Use Dart 3.9+ Git tag version solving so Crisplib and GraphX can share compatible
Git versions without literal-ref source conflicts:

```yaml
dependencies:
  graphx:
    git:
      url: https://github.com/roipeker/graphx2.git
      tag_pattern: v{{version}}
    version: ^2.0.0-dev.2

  graphx_crisplib:
    git:
      url: https://github.com/roipeker/graphx-crisplib.git
      tag_pattern: v{{version}}
    version: ^0.1.0-dev.4
```

If the app does not import GraphX directly, the explicit `graphx` entry may be
omitted; Crisplib resolves it transitively.

## Licensing

Original GraphX Crisplib code is licensed under Apache-2.0.

Parts of the font/pattern data and API behavior are derived from ABA Games' MIT-licensed `crisp-game-lib`; see `THIRD_PARTY_NOTICES.md`.
