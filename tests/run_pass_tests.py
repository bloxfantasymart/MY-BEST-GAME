"""Test gamepass logic against a mock MarketplaceService, not Roblox purchases."""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/pass_service_harness.luau').read_text()
service = (root / 'src/server/Services/PassService.luau').read_text()
source = harness.replace('-- INSERT_SERVICE_SOURCE', service)
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
