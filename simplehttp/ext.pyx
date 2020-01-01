from cpython.ref cimport PyObject
from libcpp.string cimport string
from libcpp.optional cimport optional
from simplehttp cimport Request as NativeRequest, \
                        Response as NativeResponse, \
                        SimpleHttpClient as NativeSimpleHttpClient, \
                        SimpleHttpServer as NativeSimpleHttpServer
from request_handler cimport RequestHandler

from typing import Callable
from .types import Request, Response

cdef NativeResponse handle_request(PyObject* callback, const NativeRequest& nreq) nogil:
    cdef NativeResponse nresp
    with gil:
        request = Request(bytes(nreq.path).decode('ascii'),
                        bytes(nreq.data.value()) if nreq.data.has_value() else None)
        response = (<object>callback)(request)
        nresp.code = response.code
        if response.data is not None:
            nresp.data = string(bytes(response.data))
        return nresp

cdef class SimpleHttpClient:
    cdef optional[NativeSimpleHttpClient] client

    def __init__(self, host: str, port: int):
        self.client.emplace(<string>host.encode('ascii'), <unsigned short>port)

    def make_request(self, request: Request) -> Response:
        assert(self.client.has_value())
        cdef NativeRequest nreq
        cdef NativeResponse nresp

        nreq.path = request.path.encode('ascii')
        if request.data is not None:
            nreq.data = string(bytes(request.data))
        with nogil:
            nresp = self.client.value().make_request(nreq)
        return Response(nresp.code, nresp.data.value() if nresp.data.has_value() else None)

    def __del__(self):
        self.client.reset()

cdef class SimpleHttpServer:
    cdef optional[NativeSimpleHttpServer] server

    def __init__(self, address: str, port: int):
        self.server.emplace(<string>address.encode('ascii'), <unsigned short>port)

    def run(self, callback: Callable[[Request], Response]):
        assert(self.server.has_value())
        with nogil:
            self.server.value().run(RequestHandler(&handle_request, <PyObject*>callback))

    def stop(self):
        assert(self.server.has_value())
        self.server.value().stop()


    def __del__(self):
        self.server.reset()
