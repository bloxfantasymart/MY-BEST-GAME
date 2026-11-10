"""Test aura milestones and local rendering lifecycle using Roblox mocks."""
import pathlib
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
style=(root/'src/shared/AuraStyle.luau').read_text()
renderer=(root/'src/shared/AuraRenderer.luau').read_text()
renderer=renderer.replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))\n','')
client=(root/'src/client/PlayerAura.client.luau').read_text()
for line in ('local RunService=game:GetService("RunService")\n','local Players=game:GetService("Players")\n','local ReplicatedStorage=game:GetService("ReplicatedStorage")\n','local AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))\n','local AuraRenderer=require(ReplicatedStorage.Shared:WaitForChild("AuraRenderer"))\n'):
    assert line in client
    client=client.replace(line,'')
harness=(root/'tests/aura_harness.luau').read_text()
source=harness.replace('-- INSERT_STYLE','local AuraStyle=(function()\n'+style+'\nend)()').replace('-- INSERT_RENDERER','local AuraRenderer=(function()\n'+renderer+'\nend)()').replace('-- INSERT_CLIENT',client)
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
