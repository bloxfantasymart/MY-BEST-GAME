"""Lightweight static catalog/economy checks; run with python3 tests/check_config.py."""
import pathlib
import re

source = (pathlib.Path(__file__).resolve().parents[1] / 'src/shared/Config.luau').read_text()
rows = [(name, int(rarity), int(rebirth), int(income)) for name, rarity, rebirth, income in
        re.findall(r'\{"([^"\n]+)",(\d+),(\d+),(\d+)\}', source)]
assert len(rows) == 50, len(rows)
assert len({row[0] for row in rows}) == 50
assert all(1 <= rarity <= 8 and 0 <= rebirth <= 100 and income > 0 for _, rarity, rebirth, income in rows)
assert all(rows[i][2] <= rows[i+1][2] for i in range(len(rows)-1))
assert all(any(unlock <= current for _, _, unlock, _ in rows) for current in range(100))
weights = [int(x) for x in re.findall(r'\{name="(?:Standard|Shiny|Golden|Void|Glitched)", weight=(\d+)', source)]
assert sum(weights) == 10000 and len(weights) == 5, weights
print('Catalog: 50 unique entries; all rebirth tiers have an unlocked target; mutation weights total 10,000.')
