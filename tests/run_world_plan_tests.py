"""Check deterministic world placement bounds without Roblox Studio."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
source = 'local WorldPlan = (function()\n' + (root / 'src/shared/WorldPlan.luau').read_text() + '\nend)()\n' + (root / 'tests/world_plan.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
