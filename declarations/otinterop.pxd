from libcpp.memory cimport shared_ptr, unique_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp.pair cimport pair
from libcpp.optional cimport optional
from libcpp_extra cimport time_point, system_clock
from python_reference cimport PythonReference
cimport opentracing
cimport w3copentracing

cdef extern from "otinterop_span.h" namespace "otinterop" nogil:
    cdef cppclass SpanCollectedData:
        w3copentracing.SpanContext context
        optional[PythonReference] python_span
        optional[string] operation_name
        optional[time_point[system_clock]] start_time
        optional[time_point[system_clock]] finish_time
        vector[pair[opentracing.SpanReferenceType,w3copentracing.SpanContext]] references
        map[string,opentracing.Value] tags
        map[string,string] baggage
        vector[opentracing.LogRecord] logs


cdef extern from "otinterop_tracer.h" namespace "otinterop" nogil:
    cdef cppclass Tracer(opentracing.Tracer):
        ctypedef vector[shared_ptr[SpanCollectedData]] TrackedSpans
        Tracer()
        TrackedSpans consume_tracked_spans()
        unique_ptr[opentracing.Span] StartProxySpan(w3copentracing.SpanContext,PythonReference)
        opentracing.ScopeManager& ScopeManager()

        shared_ptr[Tracer] shared_from_this()
        @staticmethod
        shared_ptr[opentracing.Tracer] InitGlobal(shared_ptr[opentracing.Tracer])
