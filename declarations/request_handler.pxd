from cpython.ref cimport PyObject
from simplehttp cimport Request, Response

cdef extern from "request_handler.h" nogil:
    cdef cppclass RequestHandler:
        RequestHandler(Response (*)(PyObject*, const Request&), PyObject*)
        RequestHandler(const RequestHandler&)
