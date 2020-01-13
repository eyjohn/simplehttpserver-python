from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension
import subprocess
import os

libraries = ['w3copentracing', 'simplehttp']

if 'STATIC' in os.environ:
    link_opts = {'extra_objects': ['/usr/local/lib/libsimplehttp.a',
                                   '/usr/local/lib/libw3copentracing.a',
                                   '/usr/local/lib/libopentracing.a']}
else:
    link_opts = {'extra_link_args': subprocess.check_output(
        ['pkg-config', '--libs'] + libraries).decode('ascii').strip().split()}

extensions = [
    Extension('simplehttpserver.ext',
              ['simplehttpserver/ext.pyx', 'src/otinterop_tracer.cpp',
                  'src/otinterop_span.cpp'],
              language='c++',
              include_dirs=['src'],
              extra_compile_args=subprocess.check_output(
                  ['pkg-config', '--cflags'] + libraries).decode('ascii').strip().split(),
              **link_opts
              )]

setup(
    name='simplehttpserver',
    packages=['simplehttpserver'],
    version='1.0',
    description='A native C++ HTTP Server with inter-platform OpenTracing support.',
    author='Evgeny Yakimov',
    author_email='evgeny@evdev.me',
    url='https://github.com/eyjohn/simplehttpserver-python',
    ext_modules=cythonize(extensions, language_level=3,
                          include_path=['declarations']),
    install_requires=['w3copentracing>=0.1.5']
)
