"""Exercise the optional touch haptics policy with a fake device and clock."""
import pathlib
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
logic=(root/'src/shared/HapticController.luau').read_text()
tests=(root/'tests/haptic_controller.luau').read_text()
source='local HapticController=(function()\n'+logic+'\nend)()\n'+tests
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
