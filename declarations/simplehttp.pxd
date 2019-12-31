from libcpp.string cimport string
from libcpp.optional cimport optional

cdef extern from "simplehttp/common.h" namespace "simplehttp":
    cdef cppclass Request:
        string path
        optional[string] data

    cdef cppclass Response:
        unsigned int code
        optional[string] data

cdef extern from "simplehttp/simplehttpclient.h" namespace "simplehttp":
    cdef cppclass SimpleHttpClient:
        SimpleHttpClient(const string& host, unsigned short port)
        Response make_request(const Request& request)


cdef extern from "simplehttp/simplehttpserver.h" namespace "simplehttp::SimpleHttpServer":
    cdef cppclass Callback:
        Callback()

cdef extern from "simplehttp/simplehttpserver.h" namespace "simplehttp":
    cdef cppclass SimpleHttpServer:
        SimpleHttpServer(const string& host, unsigned short port)
        void run(Callback)
        void stop()
