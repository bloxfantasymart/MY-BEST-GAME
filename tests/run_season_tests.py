"""Run free-season and repeatable-objective tests with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
source = ''
for name in ('Season', 'RewardExtras'):
    source += f'local {name} = (function()\n' + (root / f'src/server/Services/{name}.luau').read_text() + '\nend)()\n'
source += (root / 'tests/season.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
