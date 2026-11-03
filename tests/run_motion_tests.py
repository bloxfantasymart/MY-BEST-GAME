"""Test the client motion loop with basic Roblox stubs, not actual rendering."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/motion_harness.luau').read_text()
policy = (root / 'src/shared/MotionPolicy.luau').read_text()
animation = (root / 'src/client/DisplayAnimation.client.luau').read_text()
for line in ('local ReplicatedStorage=game:GetService("ReplicatedStorage")\n',
             'local MotionPolicy=require(ReplicatedStorage.Shared:WaitForChild("MotionPolicy"))\n'):
    assert line in animation
    animation = animation.replace(line, '')
source = harness.replace('-- INSERT_POLICY', 'local MotionPolicy = (function()\n' + policy + '\nend)()')
source = source.replace('-- INSERT_ANIMATION', animation)
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
