"""Test quest reward and free box transactions without Roblox services."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
def module(path, name, strip=''):
    contents = (root / path).read_text()
    if strip:
        assert strip in contents
        contents = contents.replace(strip, '')
    return 'local ' + name + ' = (function()\n' + contents + '\nend)()\n'
source = module('src/server/Services/Progression.luau', 'Progression')
source += module('src/server/Services/RewardExtras.luau', 'RewardExtras')
source += module('src/server/Services/MysteryBoxes.luau', 'MysteryBoxes')
source += module('src/server/Services/QuestRewards.luau', 'QuestRewards', 'local Progression=require(script.Parent.Progression)\nlocal RewardExtras=require(script.Parent.RewardExtras)\n')
source += (root / 'tests/quest_rewards.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
