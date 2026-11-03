"""Exercise elapsed-time income integration outside Roblox."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
stand = (root / 'src/shared/StandLayout.luau').read_text()
economy = (root / 'src/server/Services/PlotEconomy.luau').read_text().replace('local ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal StandLayout=require(ReplicatedStorage.Shared:WaitForChild("StandLayout"))\n', '')
source = 'local StandLayout = (function()\n' + stand + '\nend)()\nlocal PlotEconomy = (function()\n' + economy + '\nend)()\n' + (root / 'tests/income_time.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
