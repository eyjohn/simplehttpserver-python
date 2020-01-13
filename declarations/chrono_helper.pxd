cdef extern from "chrono_helper.h" nogil:
    double time_point_as_double[T](const T&)
