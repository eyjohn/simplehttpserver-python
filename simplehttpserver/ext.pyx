from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref, preincrement as inc
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.optional cimport optional
from libcpp.memory cimport shared_ptr, make_shared
from simplehttp cimport Request as NativeRequest, \
                        Response as NativeResponse, \
                        SimpleHttpClient as NativeSimpleHttpClient, \
                        SimpleHttpServer as NativeSimpleHttpServer
from request_handler cimport RequestHandler
from chrono_helper cimport time_point_as_double
from python_reference cimport PythonReference
from opentracing cimport Scope as NativeScope, \
                         Span as NativeOpenTracingSpan
from w3copentracing cimport SpanContext as NativeSpanContext
from otinterop cimport SpanCollectedData as NativeSpanCollectedData, \
                       Span as NativeSpan, \
                       Tracer as NativeTracer, dynamic_cast_span_ptr

from typing import Callable
from .types import Request, Response
from w3copentracing import Span
from opentracing import global_tracer
from contextlib import contextmanager

include "util.pxi"

# Load Tracing
cdef shared_ptr[NativeTracer] tracer
tracer = make_shared[NativeTracer]()
deref(tracer).InitGlobal(tracer)

cdef observe_spans():
    """Consume tracing events and propagate them in Python"""
    cdef vector[shared_ptr[NativeSpanCollectedData]] spans_data
    native_span_datas = deref(tracer).consume_tracked_spans()
    cdef vector[shared_ptr[NativeSpanCollectedData]].iterator it = native_span_datas.begin()
    while it != native_span_datas.end():
        process_span_data(deref(deref(it)))
        inc(it)

cdef process_span_data(NativeSpanCollectedData& data):
    if not data.python_span.has_value():
        # First time we've seen the span. Need to create it:
        context = native_to_span_context(data.context)
        operation_name = data.operation_name.value() if data.operation_name.has_value() else None

        # No start_time should not happen and would be populated interop tracer
        start_time = time_point_as_double(data.start_time.value()) if data.start_time.has_value() else None
        assert(start_time)

        references = native_to_references(data.references)
        tags = native_to_tags(data.tags)

        span = global_tracer().start_span(operation_name=operation_name,
                                          child_of=None,
                                          references=references,
                                          tags=tags,
                                          start_time=start_time,
                                          ignore_active_span=True)
        if isinstance(span, Span):
            span.context = context

        data.python_span = PythonReference(<PyObject*>span)

        # Reset consumed fields
        data.operation_name.reset()
        data.start_time.reset()
        data.references.clear()
        data.tags.clear()
    else:
        span = <object>data.python_span.value().get()

    tags = native_to_tags(data.tags)
    if tags is not None:
        for key, value in tags.items():
            span.set_tag(key, value)
        data.tags.clear()

    logs = native_to_logs(data.logs)
    if logs is not None:
        for key_values, timestamp in logs:
            span.log_kv(key_values, timestamp)
        data.logs.clear()

    if data.finish_time.has_value():
        finish_time = time_point_as_double(data.finish_time.value())
        span.finish(finish_time)

cdef class SimpleHttpServer:
    cdef optional[NativeSimpleHttpServer] server

    @staticmethod
    cdef NativeResponse handle_request(PyObject* callback, const NativeRequest& nreq) nogil:
        # Re-entry point
        cdef NativeResponse nresp
        cdef shared_ptr[NativeOpenTracingSpan] active_base_span = deref(tracer).ScopeManager().ActiveSpan()
        cdef NativeSpan* active_span = dynamic_cast_span_ptr(active_base_span.get())

        with gil:
            # Gather any tracing data during request, especially for active span.
            observe_spans()

            # Normal request handling.
            request = Request(bytes(nreq.path).decode('ascii'),
                            bytes(nreq.data.value()) if nreq.data.has_value() else None)

            if active_span:
                scope = global_tracer().scope_manager.activate(<object>deref(active_span).data().python_span.value().get(), False)
            else:
                scope = contextmanager(lambda: iter(None))

            with scope:
                response = (<object>callback)(request)
                nresp.code = response.code
                if response.data is not None:
                    nresp.data = string(bytes(response.data))

            return nresp


    def __init__(self, address: str, port: int):
        self.server.emplace(<string>address.encode('ascii'), <unsigned short>port)

    def run(self, callback: Callable[[Request], Response]):
        assert(self.server.has_value())
        with nogil:
            self.server.value().run(RequestHandler(&SimpleHttpServer.handle_request, <PyObject*>callback))

        # Handle tracing data on shutdown
        observe_spans()

    def stop(self):
        assert(self.server.has_value())
        self.server.value().stop()

    def __del__(self):
        self.server.reset()
