from distutils.core import setup
from Cython.Build import cythonize
from distutils.extension import Extension

extensions = [Extension("simplehttp.ext", ['simplehttp/ext.pyx'], language='c++')]

setup(
    name="simplehttp",
    packages=["simplehttp"],
    version='1.0',
    description='A native C++ HTTP Client and Server with inter-platform OpenTracing support.',
    author='Evgeny Yakimov',
    author_email='evgeny@evdev.me',
    url='https://github.com/eyjohn/otinterop',
    ext_modules=cythonize(extensions, language_level=3)
)
