"""Run hand-picked sale logic using Luau, independently of Roblox services."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
inventory = (root / 'src/server/Services/Inventory.luau').read_text()
selected = (root / 'src/server/Services/SelectedSale.luau').read_text().replace('local Inventory=require(script.Parent.Inventory)\n', '')
ids = (root / 'src/server/Services/ItemIds.luau').read_text()
tests = (root / 'tests/selected_sale.luau').read_text()
source = 'local Inventory=(function()\n'+inventory+'\nend)()\nlocal SelectedSale=(function()\n'+selected+'\nend)()\nlocal ItemIds=(function()\n'+ids+'\nend)()\n'+tests
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
