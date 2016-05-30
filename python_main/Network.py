__author__ = 'alexisgallepe'

import time
import socket
import json
import os, sys
import subprocess
import random
import psutil
import sys
import signal
from threading import Thread, RLock
from subprocess import call
#import Queue


class Receiver(Thread):

    def __init__(self, socket, queue):

        Thread.__init__(self)
        self.receivingQueue = queue
        self.socket = socket


    def run(self):

        while True:
            message = self.socket.recv(1024)
            #print(message)
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
            self.socket.send(message.encode("utf-8"))
            print("sent to haskell")



class Network:

    def __init__(self, receivingQueue, sendingQueue):

        server_address = '/tmp/test_sock.ipc'
        # Make sure the socket does not already exist
        try:
            os.unlink(server_address)
        except OSError:
            if os.path.exists(server_address):
                print("error sock")
                raise

        self.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.socket.bind(server_address)
        self.socket.listen(5)

        connection, client_address = self.socket.accept()

        receiverThread = Receiver(connection,receivingQueue)
        senderThread = Sender(connection, sendingQueue)

        receiverThread.start()
        senderThread.start()
        print("threads started")

