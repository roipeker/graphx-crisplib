#!/usr/bin/env python3
from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit(
        "usage: python3 tool/gen_crisp_font.py /path/to/crisp-game-lib/src/textPattern.ts"
    )

source_path = Path(sys.argv[1])
source = source_path.read_text()
body = source.split("export const textPatterns = [", 1)[1].rsplit("];", 1)[0]
patterns = re.findall(r"`(.*?)`", body, re.S)

out = [
    "// Derived from ABA Games crisp-game-lib src/textPattern.ts (MIT).",
    "// See THIRD_PARTY_NOTICES.md. ASCII 0x21 (!) through 0x7e (~).",
    "const crispTextPatterns = <String>[",
]
for pattern in patterns:
    pattern = pattern.replace("\\", "\\\\").replace("'''", "\\'\\'\\'")
    out.append("  r'''" + pattern + "''',")
out.append("];")

target = Path("lib/src/font_data.dart")
target.write_text("\n".join(out) + "\n")
print(f"wrote {len(patterns)} patterns to {target}")
