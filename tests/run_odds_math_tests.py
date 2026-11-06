"""Validate per-offer and multi-slot odds against actual server roll weights."""
import pathlib
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
def module(path,name): return 'local '+name+'=(function()\n'+(root/path).read_text()+'\nend)()\n'
source='local Color3={fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}\n'
source+=module('src/shared/Config.luau','Config')+module('src/server/Services/RollOdds.luau','RollOdds')+module('src/shared/OddsMath.luau','OddsMath')+(root/'tests/odds_math.luau').read_text()
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
