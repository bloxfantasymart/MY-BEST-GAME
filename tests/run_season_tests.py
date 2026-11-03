"""Run free-season and repeatable-objective tests with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
shared = (root / 'src/shared/SeasonRewards.luau').read_text()
season = (root / 'src/server/Services/Season.luau').read_text()
require = 'local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal SeasonRewards=require(ReplicatedStorage.Shared:WaitForChild("SeasonRewards"))\n'
assert require in season
source = 'local SeasonRewards = (function()\n' + shared + '\nend)()\n'
source += 'local Season = (function()\n' + season.replace(require, '') + '\nend)()\n'
source += 'local RewardExtras = (function()\n' + (root / 'src/server/Services/RewardExtras.luau').read_text() + '\nend)()\n'
source += (root / 'tests/season.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
