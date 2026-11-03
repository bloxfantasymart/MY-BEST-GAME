"""Exercise read-only picker and shared fusion recipe without Roblox UI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name):
    return 'local ' + name + ' = (function()\n' + (root / path).read_text() + '\nend)()\n'
source = module('src/shared/FusionRecipe.luau', 'FusionRecipe')
source += module('src/shared/InventoryView.luau', 'InventoryView')
picker = (root / 'src/shared/CraftPicker.luau').read_text()
require = 'local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))\n'
assert require in picker
source += 'local CraftPicker = (function()\n' + picker.replace(require, '') + '\nend)()\n'
source += (root / 'tests/craft_picker.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
