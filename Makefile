default: all

all: build_ext

build_ext: simplehttpserver/ext.cpython-38.so

simplehttpserver/ext.cpython-38.so: simplehttpserver/ext.pyx setup.py
	python setup.py build_ext --inplace

clean:
	rm -rf build/ simplehttpserver/*.so
