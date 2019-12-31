from distutils.core import setup
from Cython.Build import cythonize
from distutils.extension import Extension
import subprocess

extensions = [
    Extension('simplehttp.ext', 
              ['simplehttp/ext.pyx'], 
              language='c++',
              include_dirs=['src'],
              extra_compile_args=subprocess.check_output(['pkg-config', '--cflags', 'simplehttp']).decode('ascii').strip().split(),
              extra_link_args=subprocess.check_output(['pkg-config', '--libs', 'simplehttp']).decode('ascii').strip().split(),
)]

setup(
    name='simplehttp',
    packages=['simplehttp'],
    version='1.0',
    description='A native C++ HTTP Client and Server with inter-platform OpenTracing support.',
    author='Evgeny Yakimov',
    author_email='evgeny@evdev.me',
    url='https://github.com/eyjohn/otinterop',
    ext_modules=cythonize(extensions, language_level=3, include_path=['declarations'])
)
