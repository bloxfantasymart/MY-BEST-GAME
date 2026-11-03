"""Validate procedural display structure using Roblox API stubs and the Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/visuals_harness.luau').read_text()
style = (root / 'src/server/Services/VisualStyle.luau').read_text()
config = (root / 'src/shared/Config.luau').read_text()
visuals = (root / 'src/server/Services/Visuals.luau').read_text()
for line in ('local TweenService=game:GetService("TweenService")\n',
             'local Debris=game:GetService("Debris")\n',
             'local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))\n',
             'local VisualStyle=require(script.Parent.VisualStyle)\n'):
    assert line in visuals
    visuals = visuals.replace(line, '')
source = harness.replace('-- INSERT_STYLE', 'local VisualStyle = (function()\n' + style + '\nend)()')
source = source.replace('-- INSERT_CONFIG', 'local Config = (function()\n' + config + '\nend)()')
source = source.replace('-- INSERT_VISUALS', 'local Visuals = (function()\n' + visuals + '\nend)()')
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
