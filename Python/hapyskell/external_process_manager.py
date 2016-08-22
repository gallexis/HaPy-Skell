__author__ = 'alexisgallepe'

from threading import Thread
import psutil
import sys
import signal
import subprocess


class external_process_manager(Thread):
    def __init__(self):
        Thread.__init__(self)

        # if ext. program still present: kill him
        self.exit_external_program()

        # when python program receives sigint: kill him then kill ext. program
        signal.signal(signal.SIGINT, self.signal_handler)

    def run(self):

        # Run ext. program
        p = subprocess.Popen(["./../../haskell_core.hsproj/Haskell_core"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        p.communicate()


    # Exit haskell_core
    def signal_handler(self, signal, frame):
        self.exit_external_program()
        print("Exit")
        sys.exit(0)


    def exit_external_program(self):
        PROCNAME = "Haskell_core"

        for proc in psutil.process_iter():
            try:
                if proc.name() == PROCNAME:
                    proc.kill()
                    break
            except:
                pass


