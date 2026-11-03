"""Run fusion and plot-economy tests with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name):
    return 'local ' + name + ' = (function()\n' + (root / path).read_text() + '\nend)()\n'
source = module('src/shared/FusionRecipe.luau', 'FusionRecipe')
fusion = (root / 'src/server/Services/Fusion.luau').read_text()
fusion = fusion.replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))\n', '')
source += 'local Fusion = (function()\n' + fusion + '\nend)()\n'
source += module('src/server/Services/PlotEconomy.luau', 'PlotEconomy')
source += module('src/server/Services/Progression.luau', 'Progression')
source += (root / 'tests/fusion_economy.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
