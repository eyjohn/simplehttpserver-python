#include <Python.h>
#include <simplehttp/common.h>

class RequestHandler {
 public:
  using Func = simplehttp::Response (*)(PyObject*, simplehttp::Request const&);

  RequestHandler(Func func, PyObject* object) : func_(func), object_(object) {
    Py_XINCREF(object_);
  }
  RequestHandler(const RequestHandler& other)
      : func_(other.func_), object_(other.object_) {
    Py_XINCREF(object_);
  }
  ~RequestHandler() { Py_XDECREF(object_); }
  simplehttp::Response operator()(const simplehttp::Request& request) {
    if (object_) {
      return func_(object_, request);
    }
    return {500, "Internal Server Error"};
  }

 private:
  Func func_;
  PyObject* object_;
};
