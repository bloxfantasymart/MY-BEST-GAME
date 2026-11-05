"""Exercise landscape construction using structural Roblox mocks, not rendering."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
plan = (root / 'src/shared/WorldPlan.luau').read_text()
service = (root / 'src/server/Services/Environment.luau').read_text()
service = service.replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal Lighting=game:GetService("Lighting")\nlocal WorldPlan=require(ReplicatedStorage.Shared:WaitForChild("WorldPlan"))\n', '')
harness = (root / 'tests/environment.luau').read_text()
source = 'local WorldPlan = (function()\n' + plan + '\nend)()\n' + harness.replace('-- INSERT_ENVIRONMENT', 'local Environment = (function()\n' + service + '\nend)()')
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
