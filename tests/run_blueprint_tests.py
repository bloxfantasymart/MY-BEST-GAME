"""Run rare blueprint rules with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
source = 'local Blueprints = (function()\n' + (root / 'src/server/Services/Blueprints.luau').read_text() + '\nend)()\n' + (root / 'tests/blueprints.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
