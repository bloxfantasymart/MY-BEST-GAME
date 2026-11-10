"""Run pure tutorial and title logic with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
tutorial = (root / 'src/server/Services/Tutorial.luau').read_text()
titles = (root / 'src/server/Services/Titles.luau').read_text().replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))\n', '')
aura = (root / 'src/shared/AuraStyle.luau').read_text()
guide = (root / 'src/shared/TutorialGuide.luau').read_text()
tests = (root / 'tests/tutorial_titles.luau').read_text()
source = 'local AuraStyle = (function()\n' + aura + '\nend)()\n' + 'local Tutorial = (function()\n' + tutorial + '\nend)()\nlocal Titles = (function()\n' + titles + '\nend)()\nlocal Guide = (function()\n' + guide + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
