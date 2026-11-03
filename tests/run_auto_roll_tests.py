"""Test server auto-roll decisions with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
source = 'local Color3 = {fromRGB = function(r,g,b) return {r=r,g=g,b=b} end}\nlocal Config = (function()\n' + (root / 'src/shared/Config.luau').read_text() + '\nend)()\nlocal AutoRoll = (function()\n' + (root / 'src/server/Services/AutoRoll.luau').read_text() + '\nend)()\n' + (root / 'tests/auto_roll.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
