"""Test DataService with a synchronous in-memory Roblox API mock, not real DataStores."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/persistence_harness.luau').read_text()
service = (root / 'src/server/Services/DataService.luau').read_text().replace('local Loadouts=require(script.Parent.Loadouts)\n', '').replace('local SessionGifts=require(script.Parent.SessionGifts)\n', '').replace('local PersistenceStatus=require(script.Parent.PersistenceStatus)\n', '')
source = 'local PersistenceStatus = (function()\n' + (root / 'src/server/Services/PersistenceStatus.luau').read_text() + '\nend)()\n' + 'local SessionGifts = (function()\n' + (root / 'src/server/Services/SessionGifts.luau').read_text() + '\nend)()\n' + 'local Loadouts = (function()\n' + (root / 'src/server/Services/Loadouts.luau').read_text() + '\nend)()\n' + 'local CollectionIndex = (function()\n' + (root / 'src/shared/CollectionIndex.luau').read_text() + '\nend)()\n' + 'local Progression = (function()\n' + (root / 'src/server/Services/Progression.luau').read_text() + '\nend)()\n' + harness.replace('-- INSERT_SERVICE_SOURCE', service)
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
