"""Run admin authorization and validation tests with the standalone Luau CLI."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
logic = (root / 'src/server/Services/AdminService.luau').read_text()
tests = (root / 'tests/admin_logic.luau').read_text()
source = 'local AdminService = (function()\n' + logic + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
