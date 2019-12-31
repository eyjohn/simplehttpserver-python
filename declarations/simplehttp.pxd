from libcpp.string cimport string
from libcpp.optional cimport optional
from libcpp.functional cimport function

cdef extern from "simplehttp/common.h" namespace "simplehttp" nogil:
    cdef cppclass Request:
        string path
        optional[string] data

    cdef cppclass Response:
        unsigned int code
        optional[string] data

cdef extern from "simplehttp/simplehttpclient.h" namespace "simplehttp" nogil:
    cdef cppclass SimpleHttpClient:
        SimpleHttpClient(const string& host, unsigned short port)
        Response make_request(const Request& request)

cdef extern from "simplehttp/simplehttpserver.h" namespace "simplehttp" nogil:
    cdef cppclass SimpleHttpServer:
        SimpleHttpServer(const string& address, unsigned short port)
        void run[T](T)
        void stop()
