"""Run pure configuration tests with the standalone Luau CLI (pass its path as argv[1])."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
config = (root / 'src/shared/Config.luau').read_text()
tests = (root / 'tests/config_runtime.luau').read_text()
source = 'local Color3 = {fromRGB = function(r,g,b) return {r=r,g=g,b=b} end}\nlocal Config = (function()\n' + config + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
