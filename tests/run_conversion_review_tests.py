"""Exercise reviewed assembly/fusion with the actual transaction modules."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name, remove=()):
    text = (root / path).read_text()
    for line in remove:
        assert line in text
        text = text.replace(line, '')
    return f'local {name} = (function()\n' + text + '\nend)()\n'
rs='local ReplicatedStorage=game:GetService("ReplicatedStorage")\n'
source = module('src/shared/CraftMath.luau','CraftMath')
source += module('src/shared/FusionRecipe.luau','FusionRecipe')
source += module('src/server/Services/Blueprints.luau','Blueprints')
source += module('src/server/Services/Inventory.luau','Inventory')
source += module('src/server/Services/Crafting.luau','Crafting',[rs,'local CraftMath=require(ReplicatedStorage.Shared:WaitForChild("CraftMath"))\n','local Blueprints=require(script.Parent.Blueprints)\n','local Inventory=require(script.Parent.Inventory)\n'])
source += module('src/server/Services/Fusion.luau','Fusion',[rs,'local FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))\n'])
source += module('src/server/Services/ConversionReviews.luau','Reviews')
source += module('src/server/Services/ItemIds.luau','ItemIds')
source += (root / 'tests/conversion_reviews.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
