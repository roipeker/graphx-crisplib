## 0.1.0-dev.4

- Move game identity, title, description, seed, and logical-stage settings into `CrispGameConfig`.
- Make `description` optional.
- Cache the resolved game config in the runtime.

## 0.1.0-dev.3

- Label generated 6x6 font glyphs with their ASCII character and Unicode code point.
- Generate named ASCII bounds used by atlas lookup.
- Ensure generated font glyphs obey the current draw color through `char()`.

## 0.1.0-dev.2

- Use Git tag-pattern version solving for GraphX.
- Keep stage clipping enabled by default.

## 0.1.0-dev.1

- Initial public extraction from the Crisp Games GraphX experiment.
- Fixed-step immediate-mode game runtime.
- Crisp-compatible 6x6 characters and text atlas.
- Variable-size atlas-backed sprite clips.
- Pixel lines, arcs, circles, particles, input, score and draw-order collision queries.
- Responsive logical-stage scaling and clipped stage output.
