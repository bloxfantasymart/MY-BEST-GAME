"""Run session gift and roll-expiration logic with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
logic = (root / 'src/server/Services/SessionGifts.luau').read_text()
tests = (root / 'tests/session_gifts.luau').read_text()
config = (root / 'src/shared/Config.luau').read_text()
source = 'local Color3 = {fromRGB = function(r,g,b) return {r=r,g=g,b=b} end}\nlocal Config = (function()\n' + config + '\nend)()\nlocal SessionGifts = (function()\n' + logic + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
