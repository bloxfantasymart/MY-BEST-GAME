"""Test read-only booth descriptions and browsing without Roblox services."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name):
    return 'local ' + name + ' = (function()\n' + (root / path).read_text() + '\nend)()\n'
source = module('src/server/Services/ShowcaseView.luau', 'ShowcaseView')
source += module('src/shared/ShowcaseInventory.luau', 'ShowcaseInventory')
source += module('src/shared/InventoryView.luau', 'InventoryView')
source += (root / 'tests/showcase_view.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
