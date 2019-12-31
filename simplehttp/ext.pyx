from libcpp.string cimport string
from libcpp.optional cimport optional
from simplehttp cimport Request as NativeRequest, \
                        Response as NativeResponse, \
                        SimpleHttpClient as NativeSimpleHttpClient, \
                        SimpleHttpServer as NativeSimpleHttpServer
from python_callable cimport PythonCallable
from .types import Request, Response

cdef class SimpleHttpClient:
    cdef optional[NativeSimpleHttpClient] client

    def __init__(self, host: str, port: int):
        self.client = NativeSimpleHttpClient(host.encode('ascii'), port)

    def make_request(self, request: Request) -> Response:
        assert(self.client.has_value())
        cdef NativeRequest nreq
        cdef NativeResponse nresp

        nreq.path = request.path.encode('ascii')
        if request.data is not None:
            nreq.data = string(bytes(request.data))

        nresp = self.client.value().make_request(nreq)
        return Response(nresp.code, nresp.data.value() if nresp.data.has_value() else None)

    def __del__(self):
        self.client.reset()

cdef class SimpleHttpServer:
    pass
