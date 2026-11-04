"""Test token-backed nine-offer rolling with the actual ID allocator."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
item_ids = (root / 'src/server/Services/ItemIds.luau').read_text()
service = (root / 'src/server/Services/MultiRoll.luau').read_text().replace('local ItemIds=require(script.Parent.ItemIds)\n', '')
source = 'local ItemIds = (function()\n' + item_ids + '\nend)()\nlocal MultiRoll = (function()\n' + service + '\nend)()\n' + (root / 'tests/multi_roll.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
