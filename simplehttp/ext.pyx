from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.optional cimport optional
from libcpp.memory cimport shared_ptr, make_shared
from simplehttp cimport Request as NativeRequest, \
                        Response as NativeResponse, \
                        SimpleHttpClient as NativeSimpleHttpClient, \
                        SimpleHttpServer as NativeSimpleHttpServer
from request_handler cimport RequestHandler
from otinterop cimport Scope as NativeScope, \
                       Span as NativeSpan, \
                       SpanCollectedData as NativeSpanCollectedData, \
                       SpanContext as NativeSpanContext, \
                       Tracer as NativeTracer

from typing import Callable
from .types import Request, Response
from opentracing import global_tracer

include "util.pxi"

# Load Tracing
cdef shared_ptr[NativeTracer] tracer
tracer = make_shared[NativeTracer]()
deref(tracer).InitGlobal(deref(tracer).shared_from_this())

# Re-entry point
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

        cdef NativeSpanContext native_context
        cdef shared_ptr[NativeSpan] native_span_ptr
        cdef optional[NativeScope] native_scope
        scope = global_tracer().scope_manager.active

        # Reinstantiate the active scope in C++ if exists in python
        if scope is not None:
            span_context_to_native(scope.span.context, native_context)
            native_span_ptr = shared_ptr[NativeSpan](deref(tracer).StartProxySpan(native_context))
            native_scope.emplace(deref(tracer).ScopeManager().Activate(native_span_ptr))
            # Scope lives until and of call

        # Convert the request
        cdef NativeRequest nreq
        cdef NativeResponse nresp
        nreq.path = request.path.encode('ascii')
        if request.data is not None:
            nreq.data = string(bytes(request.data))

        # Make the request
        with nogil:
            nresp = self.client.value().make_request(nreq)

        # Convert the response
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
