"""Run offer reroll and discard review tests without Roblox."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
source = 'local OfferSafety = (function()\n' + (root / 'src/shared/OfferSafety.luau').read_text() + '\nend)()\n' + (root / 'tests/offer_safety.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
