import time
import json
import os
import subprocess
import random
import queue as queue
from python_main import Network
from python_main import external_process_manager as etm

if "__main__" == __name__:

    receivingQueue = queue.Queue()
    sendingQueue = queue.Queue()

    networkTread = Network.Network(receivingQueue, sendingQueue)

    #Be sure receiver is waiting for client
    time.sleep(1)
    epm = etm.external_process_manager()
    epm.start()

    time.sleep(5)
    sendingQueue.put({"order":"test","message":"python to haskell1"})
    sendingQueue.put({"order":"test","message":"python to haskell2"})
    sendingQueue.put({"order":"test","message":"python to haskell3"})
    print("sent to sendingQueue")