"""Test server-owned parkour progression without Roblox physics."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
service = (root / 'src/server/Services/Obby.luau').read_text()
tests = (root / 'tests/obby.luau').read_text()
source = 'local Obby = (function()\n' + service + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
