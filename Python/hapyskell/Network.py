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
            try:
                message = self.socket.recv(1024)
                if len(message) == 0:
                    break

                decodedMessage = json.loads(message.decode("utf-8") )
                print("new message: ")
                print(decodedMessage)
                self.receivingQueue.put(decodedMessage)

            except Exception as e:
                print("socket error {} ".format(e))
                self.socket.close()
                break



class Sender(Thread):

    def __init__(self, socket, queue):

        Thread.__init__(self)
        self.socket = socket
        self.sendingQueue = queue

    def run(self):
        while True:
            message = self.sendingQueue.get()

            try:
                self.socket.send(message.encode("utf-8"))
                print("sent to haskell")

            except Exception as e:
                print("socket error {} ".format(e))
                self.socket.close()
                break




class Network(Thread):

    def __init__(self, receivingQueue, sendingQueue):
        Thread.__init__(self)

        self.receivingQueue = receivingQueue
        self.sendingQueue   = sendingQueue

        server_address = '/tmp/test_sock.ipc'

        # Make sure the socket does not already exists
        try:
            os.unlink(server_address)
        except OSError:
            if os.path.exists(server_address):
                print("error sock")
                raise

        self.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.socket.bind(server_address)
        self.socket.listen(5)

    def run(self):
        connected_socket, client_address = self.socket.accept()

        receiverThread = Receiver(connected_socket,self.receivingQueue)
        senderThread = Sender(connected_socket, self.sendingQueue)

        receiverThread.start()
        senderThread.start()
