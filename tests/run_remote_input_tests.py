"""Test remote envelopes and verify literal client actions remain routable."""
import pathlib
import re
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
logic=(root/'src/server/Services/RemoteInput.luau').read_text()
gate=(root/'src/server/Services/InteractionGate.luau').read_text()
tests=(root/'tests/remote_input.luau').read_text()
coverage=[]
for place,path in [('main','src/client/Main.client.luau'),('hub','src/hub/Hub.client.luau')]:
    actions=set(re.findall(r':FireServer\("([^\"]+)"',(root/path).read_text()))
    if place=='main': actions.update(['saveStandLayout','deleteStandLayout'])
    for action in sorted(actions):
        coverage.append(f'assert(RemoteInput.accept("{place}","{action}",nil) or RemoteInput.accept("{place}","{action}",false) or RemoteInput.accept("{place}","{action}","x") or RemoteInput.accept("{place}","{action}",1) or RemoteInput.accept("{place}","{action}",{{}}), "Missing client action {place}:{action}")')
source='local RemoteInput=(function()\n'+logic+'\nend)()\nlocal InteractionGate=(function()\n'+gate+'\nend)()\n'+tests+'\n'+'\n'.join(coverage)+'\nprint("All literal client actions have a supported envelope")\n'
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
