"""Test shared crafting math and server-side atomic assembly with Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name):
    text = (root / path).read_text()
    if name == 'Crafting':
        text = text.replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\n', '')
        text = text.replace('local CraftMath=require(ReplicatedStorage.Shared:WaitForChild("CraftMath"))\n', '')
        text = text.replace('local Blueprints=require(script.Parent.Blueprints)\n', '')
        text = text.replace('local Inventory=require(script.Parent.Inventory)\n', '')
    return f'local {name} = (function()\n' + text + '\nend)()\n'
source = module('src/shared/CraftMath.luau','CraftMath')
source += module('src/server/Services/Blueprints.luau','Blueprints')
source += module('src/server/Services/Inventory.luau','Inventory')
source += module('src/server/Services/Crafting.luau','Crafting')
source += (root / 'tests/crafting.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
