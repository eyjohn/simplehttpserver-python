from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.unordered_map cimport unordered_map
from libcpp.pair cimport pair
from libcpp_extra cimport time_point, system_clock

cdef extern from "opentracing/propagation.h" namespace "opentracing" nogil:
    cdef cppclass SpanReferenceType:
        pass

cdef extern from "opentracing/propagation.h" namespace "opentracing::SpanReferenceType" nogil:
    cdef SpanReferenceType ChildOfRef
    cdef SpanReferenceType FollowsFromRef

cdef extern from "opentracing/string_view.h" namespace "opentracing::util" nogil:
    cdef cppclass string_view:
        const char* data() const

# This isn't the right header, but didn't want to expose variant
cdef extern from "opentracing/value.h" namespace "opentracing::util" nogil:
    cdef cppclass recursive_wrapper[T]:
        T& get()

cdef extern from "opentracing/value.h" namespace "opentracing" nogil:
    cdef cppclass Value:
        bool is_type "is" [T]()
        T& get[T]()
    
    ctypedef unordered_map[string, Value] Dictionary
    ctypedef vector[Value] Values

cdef extern from "opentracing/span.h" namespace "opentracing" nogil:
    cdef cppclass LogRecord:
        ctypedef pair[string, Value] Field
        time_point[system_clock] timestamp
        vector[Field] fields

    cdef cppclass Span:
        pass
    
    cdef cppclass SpanContext:
        pass

cdef extern from "opentracing/scope_manager.h" namespace "opentracing" nogil:
    cdef cppclass Scope:
        pass

    cdef cppclass ScopeManager:
          Scope Activate(shared_ptr[Span])
          shared_ptr[Span] ActiveSpan()

cdef extern from "opentracing/tracer.h" namespace "opentracing" nogil:
    cdef cppclass Tracer:
        pass