#pragma once

#include <Python.h>

class PythonReference {
 public:
  PythonReference(PyObject* object = nullptr) : object_(object) {
    Py_XINCREF(object_);
  }
  PythonReference(const PythonReference& other) : object_(other.object_) {
    Py_XINCREF(object_);
  }
  PythonReference& operator=(const PythonReference& other) {
    if (this != &other) {
      Py_XDECREF(object_);
      object_ = other.object_;
      Py_XINCREF(object_);
    }
    return *this;
  }
  ~PythonReference() { Py_XDECREF(object_); }
  PyObject* get() const { return object_; }

 private:
  PyObject* object_;
};
