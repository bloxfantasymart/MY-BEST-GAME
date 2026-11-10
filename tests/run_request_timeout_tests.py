"""Exercise review timeouts and verify all review UIs install a timeout."""
import pathlib
import subprocess
import sys
import tempfile
root=pathlib.Path(__file__).resolve().parents[1]
logic=(root/'src/shared/RequestTimeout.luau').read_text()
tests=(root/'tests/request_timeout.luau').read_text()
main=(root/'src/client/Main.client.luau').read_text()
hub=(root/'src/hub/Hub.client.luau').read_text()
for name in ('batchPurchaseWaiting','purchaseWaiting','craftWaiting','forgeWaiting','layoutWaiting','refineWaiting','chosenSaleWaiting','duplicateWaiting','singleSaleWaiting','bulkWaiting'):
    assert main.count('watchReview('+name+',')==1, f'{name} must have exactly one timeout at request creation'
assert 'RequestTimeout.watch(task.delay' in hub and 'directoryWaiting==expected' in hub
source='local RequestTimeout=(function()\n'+logic+'\nend)()\n'+tests
with tempfile.NamedTemporaryFile(mode='w',suffix='.luau',encoding='utf8') as file:
    file.write(source); file.flush()
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',file.name],check=True)
