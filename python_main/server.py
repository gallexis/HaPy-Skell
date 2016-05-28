#
#   Hello World server in Python
#   Binds REP socket to tcp://*:5555
#   Expects b"Hello" from client, replies with b"World"
#

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
            print("Received: ")
            print(message)

            self.socket.send(b"ack")


thread_1 = Network()
thread_1.start()

#call(["./client", " > log"])
#os.spawnl(os.P_NOWAIT, "./client > log")

subprocess.Popen(["./../haskell_core/Haskell_core"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print("haskell started")

thread_1.join()
print("end")

