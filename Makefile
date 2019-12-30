default: all

all: build_ext

build_ext: simplehttp/ext.cpython-38.so

simplehttp/ext.cpython-38.so: simplehttp/ext.pyx
	python setup.py build_ext --inplace

clean:
	rm *.so *.o
