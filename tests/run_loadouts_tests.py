"""Test saved stand-layout validation and atomic application without Roblox."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
stand = (root / 'src/shared/StandLayout.luau').read_text()
loadouts = (root / 'src/server/Services/Loadouts.luau').read_text()
tests = (root / 'tests/loadouts.luau').read_text()
source = 'local StandLayout = (function()\n' + stand + '\nend)()\nlocal Loadouts = (function()\n' + loadouts + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
