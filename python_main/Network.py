__author__ = 'alexisgallepe'

import time
import zmq
import json
import os
import subprocess
import random
import psutil
import sys
import signal
from threading import Thread, RLock
from subprocess import call
#import Queue


class Receiver(Thread):

    def __init__(self, queue):
        Thread.__init__(self)

        self.receivingQueue = queue
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.PAIR)
        self.socket.bind("ipc:///tmp/1")

    def run(self):

        while True:
            message = self.socket.recv()
            decodedMessage = json.loads(message.decode("utf-8") )
            print("new message: ")
            print(decodedMessage)
            self.receivingQueue.put(decodedMessage)


class Sender(Thread):

    def __init__(self, socket, queue):
        Thread.__init__(self)

        self.socket = socket
        self.sendingQueue = queue

    def run(self):
        while True:
            message = self.sendingQueue.get()
            self.socket.send_json(message)
            print("sent to haskell")

class Network:

    def __init__(self, receivingQueue, sendingQueue):
        receiverThread = Receiver(receivingQueue)
        senderThread = Sender(receiverThread.socket, sendingQueue)

        receiverThread.start()
        senderThread.start()
        print("threads started")

