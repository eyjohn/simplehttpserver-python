#include <Python.h>

class PythonCallable {
 public:
  PythonCallable(PyObject* object) : object_(object) { Py_XINCREF(object_); }
  PythonCallable(const PythonCallable& other) : object_(other.object_) {
    Py_XINCREF(object_);
  }
  ~PythonCallable() { Py_XDECREF(object_); }
  void operator()() {
    if (object_) {
      Py_XDECREF(PyObject_CallObject(object_, nullptr));
    }
  }

 private:
  PyObject* object_;
};
