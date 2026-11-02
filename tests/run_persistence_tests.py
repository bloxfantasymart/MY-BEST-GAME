"""Test DataService with a synchronous in-memory Roblox API mock, not real DataStores."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/persistence_harness.luau').read_text()
service = (root / 'src/server/Services/DataService.luau').read_text()
source = harness.replace('-- INSERT_SERVICE_SOURCE', service)
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
