#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$root/Pro_Voice_Chain.jsfx"
dst="$root/Pro_Voice_Chain_ysfx.jsfx"

python3 - "$src" "$dst" <<'PY'
from pathlib import Path
import re
import sys

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
text = src.read_text()

text = re.sub(
    r"^desc:Pro Voice Chain v([^\n]+?) - VoiceOver Unified Chain$",
    r"desc:Pro Voice Chain v\1 ySFX - VoiceOver Unified Chain",
    text,
    count=1,
    flags=re.MULTILINE,
)

replacement = """function show_slider_range(lo, hi)
local(j)
(
  // ySFX compatibility: REAPER slider visibility API is not portable.
  j = lo;
);

function apply_host_slider_visibility(show_host)
local(i, page)
(
  page = clamp(floor(compact_page + 0.5), 0, 8);
  ui_host_visibility_state != show_host || ui_host_page_state != page ? (
    ui_host_visibility_state = show_host;
    ui_host_page_state = page;
  );
);"""

pattern = re.compile(
    r"function show_slider_range\(lo, hi\)\n"
    r"local\(j\)\n"
    r"\(\n"
    r".*?\n"
    r"\);\n\n"
    r"function apply_host_slider_visibility\(show_host\)\n"
    r"local\(i, page\)\n"
    r"\(\n"
    r".*?\n"
    r"\);",
    re.DOTALL,
)

text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit("Could not replace slider visibility functions")

if re.search(r"(^|[^A-Za-z0-9_])slider_show\s*\(", text):
    raise SystemExit("ySFX variant still contains slider_show() call")

dst.write_text(text)
PY

echo "Wrote $dst"
