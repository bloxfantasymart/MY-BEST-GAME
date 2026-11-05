"""Test server-reviewed scrap conversions and actual mystery-box opening."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name):
    return f'local {name} = (function()\n' + (root / path).read_text() + '\nend)()\n'
source = module('src/server/Services/ScrapRefinery.luau','Refinery')
source += module('src/server/Services/MysteryBoxes.luau','MysteryBoxes')
source += (root / 'tests/refinery.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
