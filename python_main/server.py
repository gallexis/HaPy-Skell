import time
import zmq
import json
import os
import subprocess
import random
import sys
from threading import Thread, RLock
from subprocess import call


class Network(Thread):

    def __init__(self):
        Thread.__init__(self)

        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REP)
        self.socket.bind("ipc:///tmp/1")

    def run(self):
        while True:

            message = self.socket.recv()
            print("Received: "+str(message))
            a = json.loads(message.decode("utf-8") )
            print(a["message"])
            self.socket.send(json.dumps({"order":"python","message":"hello"}).encode("utf-8"))


thread_1 = Network()
thread_1.start()

subprocess.Popen(["./../haskell_core/Haskell_core"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print("haskell started")

thread_1.join()
print("end")

