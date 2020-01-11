from cpython.bytes cimport PyBytes_FromStringAndSize
from cython.operator cimport dereference as deref, preincrement as inc
from otinterop cimport SpanContext as NativeSpanContext
from w3copentracing import SpanContext
from libcpp.string cimport string
from libcpp.map cimport map


cdef bytes_to_mem(bytes src, char* dst, int size):
    assert(len(src) >= size)
    for i in range(size):
        dst[i] = src[i]

cdef bytes mem_to_bytes(char* src, int size):
    return PyBytes_FromStringAndSize(src,size)

cdef baggage_to_native(dict baggage, map[string,string]& native):
    if baggage is not None:
        for k,v in baggage.items():
            native[k.encode("ascii")] = v.encode("ascii")

cdef object native_to_baggage(map[string,string]& native):
    out = dict()
    cdef map[string,string].iterator it = native.begin()
    while it != native.end():
        out[bytes(deref(it).first).decode("ascii")] = bytes(deref(it).first).decode("ascii")
        inc(it)
    return out

cdef span_context_to_native(context: SpanContext, NativeSpanContext& native):
    assert(len(context.trace_id) == native.trace_id.size())
    assert(len(context.span_id) == native.span_id.size())
    bytes_to_mem(context.trace_id, <char*>native.trace_id.data(), native.trace_id.size())
    bytes_to_mem(context.span_id, <char*>native.span_id.data(), native.span_id.size())
    native.sampled = context.sampled
    baggage_to_native(context.baggage, native.baggage)

cdef object native_to_span_context(NativeSpanContext& native):
    return SpanContext(
        trace_id=mem_to_bytes(<char*>native.trace_id.data(), native.trace_id.size()),
        span_id=mem_to_bytes(<char*>native.span_id.data(), native.span_id.size()),
        sampled=native.sampled,
        baggage=native_to_baggage(native.baggage)
    )

