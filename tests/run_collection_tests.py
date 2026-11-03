"""Run pure, informational catalog-discovery tests with standalone Luau."""
import pathlib
import subprocess
import sys
import tempfile
root = pathlib.Path(__file__).resolve().parents[1]
module = (root / 'src/shared/CollectionIndex.luau').read_text()
tests = (root / 'tests/collection_index.luau').read_text()
source = 'local CollectionIndex = (function()\n' + module + '\nend)()\n' + tests
with tempfile.NamedTemporaryFile(mode='w', suffix='.luau', encoding='utf8') as file:
    file.write(source)
    file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', file.name], check=True)
