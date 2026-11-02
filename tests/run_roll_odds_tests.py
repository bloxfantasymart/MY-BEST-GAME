"""Test actual roll odds and disclosures using the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
config = (root / 'src/shared/Config.luau').read_text()
logic = (root / 'src/server/Services/RollOdds.luau').read_text()
tests = (root / 'tests/roll_odds.luau').read_text()
source = 'local Color3 = {fromRGB = function(r,g,b) return {r=r,g=g,b=b} end}\nlocal Config = (function()\n' + config + '\nend)()\nlocal RollOdds = (function()\n' + logic + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
