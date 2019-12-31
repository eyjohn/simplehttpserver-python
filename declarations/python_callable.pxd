from cpython.ref cimport PyObject

cdef extern from "python_callable.h":
    cdef cppclass PythonCallable:
        PythonCallable(PyObject*)
        PythonCallable(const PythonCallable&)
