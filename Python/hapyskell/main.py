import json
import queue as queue

from python_core.hapyskell import Network
from python_core.hapyskell import external_process_manager as etm

# cd haskell_core.hsproj/ ;and  ghc Haskell_core.hs ;and cd ..

if "__main__" == __name__:

    receivingQueue = queue.Queue()
    sendingQueue = queue.Queue()

    networkTread = Network.Network(receivingQueue, sendingQueue)
    networkTread.start()

    epm = etm.external_process_manager()
    epm.start()

    #test
    sendingQueue.put(json.dumps({"order":"display_message","message":"python to haskell1"}))
