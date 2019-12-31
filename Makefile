default: all

all: build_ext

build_ext: ext.cpython-38.so

ext.cpython-38.so: simplehttp/ext.pyx setup.py
	python setup.py build_ext --inplace

clean:
	rm *.so *.o
