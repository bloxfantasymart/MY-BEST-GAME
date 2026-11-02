"""Run progression and UTC event logic with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
progression = (root / 'src/server/Services/Progression.luau').read_text()
events = (root / 'src/server/Services/LiveEvents.luau').read_text()
tests = (root / 'tests/progression.luau').read_text()
source = 'local Progression = (function()\n' + progression + '\nend)()\nlocal LiveEvents = (function()\n' + events + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
