from cpython.ref cimport PyObject

cdef extern from "python_reference.h" nogil:
    cdef cppclass PythonReference:
        PythonReference(PyObject*)
        PythonReference(const PythonReference&)
        PyObject* get() const
