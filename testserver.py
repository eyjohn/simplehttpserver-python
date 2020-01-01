import signal
import threading
import time
import sys

from simplehttp import Request,Response,SimpleHttpServer

if len(sys.argv) != 3:
    print("Usage: python testserver.py <address> <port>")
    sys.exit(1)

server = SimpleHttpServer(sys.argv[1], int(sys.argv[2]))
cb = lambda r: Response(200, ("Responding for: "+r.path).encode("ascii"))

def thread_func():
    server.run(cb)

x = threading.Thread(target=thread_func)
x.start()

sig = signal.sigwait([signal.SIGINT,signal.SIGTERM])

server.stop()
x.join()
