"""Exercise save-status disclosure and manual checkpoint throttling with Luau."""
import pathlib
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
def module(path,name):
    return 'local '+name+'=(function()\n'+(root/path).read_text()+'\nend)()\n'
source=module('src/server/Services/PersistenceStatus.luau','PersistenceStatus')+module('src/server/Services/CheckpointRequest.luau','CheckpointRequest')+(root/'tests/save_status.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
