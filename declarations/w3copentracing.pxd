from libc.stdint cimport uint8_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map
from libcpp_extra cimport array
cimport opentracing


cdef extern from "w3copentracing/span_context.h" namespace "w3copentracing" nogil:
    # Cython Hacks
    cdef cppclass int_value_8 "8":
        pass
    cdef cppclass int_value_16 "16":
        pass

    cdef cppclass SpanContext(opentracing.SpanContext):
        ctypedef array[uint8_t,int_value_16] TraceID
        ctypedef array[uint8_t,int_value_8] SpanID
        ctypedef map[string,string] Baggage

        SpanContext()
        SpanContext(const TraceID&, const SpanID&, bool, const Baggage&)

        TraceID trace_id
        SpanID span_id
        bool sampled
        Baggage baggage

        @staticmethod
        SpanID GenerateSpanID()

        @staticmethod
        TraceID GenerateTraceID()
