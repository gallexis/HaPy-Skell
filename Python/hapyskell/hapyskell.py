import json
import queue as queue

from Python.hapyskell import Network
from Python.hapyskell import external_process_manager as epm

# cd haskell_core.hsproj/ ;and  ghc Haskell_core.hs ;and cd ..

if "__main__" == __name__:

    receivingQueue = queue.Queue()
    sendingQueue = queue.Queue()

    networkTread = Network.Network(receivingQueue, sendingQueue)
    networkTread.start()

    epm.external_process_manager().start()

    #test
    sendingQueue.put(json.dumps({"order":"display_message","message":"python to haskell1"}))
