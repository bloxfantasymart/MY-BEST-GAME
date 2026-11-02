"""Validate Rojo project references without requiring Studio."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
for filename in ('default.project.json', 'hub.project.json'):
    project = json.loads((root / filename).read_text())
    def check(node):
        if not isinstance(node, dict):
            return
        if '$path' in node:
            path = root / node['$path']
            assert path.exists(), f'{filename}: missing {path}'
        for value in node.values():
            check(value)
    check(project)
    print(f'{filename}: all Rojo paths exist')
