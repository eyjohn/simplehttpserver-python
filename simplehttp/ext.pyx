
from libcpp.string cimport string
from libcpp.optional cimport optional

"""
struct Request {
  std::string path;
  std::optional<std::string> data;
};

struct Response {
  unsigned int code;
  std::optional<std::string> data;
};
"""

cdef extern from "simplehttp/common.h" namespace "simplehttp":
    cdef cppclass Request:
        string path
        optional[string] data

    cdef cppclass Response:
        unsigned int code
        optional[string] data

def foo():
    cdef Request r;
    r.path = b'abc'
    r.data = string(b'bar')
    return (r.path, r.data.value())


# cdef class SomeClassWrapper:
#     cdef SomeClass sc

#     def __init__(self):
#         self.sc = SomeClass()

#     def say_hello(self, name:str):
#         self.sc.sayHello(name.encode("ascii"))

#     def multiply(self, a:int, b:int):
#         return self.sc.multiply(a, b) 
