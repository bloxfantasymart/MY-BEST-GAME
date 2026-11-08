"""Check hub skyline layout and construction with structural mocks, not Roblox physics."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
plan = (root / 'src/shared/HubWorldPlan.luau').read_text()
landscape = (root / 'src/hub/HubLandscape.luau').read_text().replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal Plan=require(ReplicatedStorage.Shared:WaitForChild("HubWorldPlan"))\n', '')
tests = (root / 'tests/hub_landscape.luau').read_text()
source = 'local Plan=(function()\n' + plan + '\nend)()\n' + tests.replace('-- INSERT_LANDSCAPE', 'local Landscape=(function()\n' + landscape + '\nend)()')
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
