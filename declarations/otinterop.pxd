from libc.stdint cimport uint8_t
from libcpp cimport bool
from libcpp.memory cimport shared_ptr, unique_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp.pair cimport pair
from libcpp.optional cimport optional
from libcpp_extra cimport array, time_point, system_clock
from python_reference cimport PythonReference

cdef extern from "opentracing/propagation.h" namespace "opentracing" nogil:
    cdef cppclass SpanReferenceType:
        pass

cdef extern from "opentracing/propagation.h" namespace "opentracing::SpanReferenceType" nogil:
    cdef SpanReferenceType ChildOfRef
    cdef SpanReferenceType FollowsFromRef

cdef extern from "opentracing/value.h" namespace "opentracing" nogil:
    cdef cppclass Value:
        pass

cdef extern from "opentracing/span.h" namespace "opentracing" nogil:
    cdef cppclass LogRecord:
        ctypedef pair[string, Value] Field
        time_point[system_clock] timestamp
        vector[Field] fields

    cdef cppclass Span:
        pass

cdef extern from "opentracing/scope_manager.h" namespace "opentracing" nogil:
    cdef cppclass Scope:
        pass

    cdef cppclass ScopeManager:
          Scope Activate(shared_ptr[Span])
          shared_ptr[Span] ActiveSpan()

cdef extern from "w3copentracing/span_context.h" namespace "w3copentracing" nogil:
    # Cython Hacks
    cdef cppclass eight "8":
        pass
    cdef cppclass sixteen "16":
        pass

    cdef cppclass SpanContext:
        ctypedef array[uint8_t,sixteen] TraceID
        ctypedef array[uint8_t,eight] SpanID
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

cdef extern from "opentracing/propagation.h" namespace "opentracing" nogil:
    cdef cppclass SpanReferenceType:
        pass

cdef extern from "otinterop_span.h" namespace "otinterop" nogil:
    cdef cppclass SpanCollectedData:
        optional[string] operation_name
        optional[time_point[system_clock]] start_time
        optional[time_point[system_clock]] finish_time
        vector[pair[SpanReferenceType,SpanContext]] references
        map[string,Value] tags
        map[string,string] baggage
        vector[LogRecord] logs
        optional[PythonReference] python_span

cdef extern from "opentracing/tracer.h" nogil:
    cdef cppclass OpentracingTracer "opentracing::Tracer":
        pass

cdef extern from "otinterop_tracer.h" namespace "otinterop" nogil:
    cdef cppclass Tracer:
        ctypedef vector[shared_ptr[SpanCollectedData]] TrackedSpans
        Tracer()
        TrackedSpans consume_tracked_spans()
        unique_ptr[Span] StartProxySpan(SpanContext,PythonReference)

        ScopeManager& ScopeManager()

        shared_ptr[OpentracingTracer] shared_from_this()
        @staticmethod
        shared_ptr[OpentracingTracer] InitGlobal(shared_ptr[OpentracingTracer])
