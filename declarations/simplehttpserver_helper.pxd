from libcpp.optional cimport optional
from libcpp.string cimport string
from simplehttp cimport SimpleHttpServer

cdef extern from "simplehttpserver_helper.h" nogil:
    cdef void instantiate(optional[SimpleHttpServer]&,const string&,unsigned short)
