from distutils.core import setup
from Cython.Build import cythonize
from distutils.extension import Extension

sourcefiles = ['simplehttp/ext.pyx']

extensions = [Extension("simplehttp.ext", sourcefiles, language='c++')]

setup(
    name="simplehttp",
    ext_modules=cythonize(extensions, language_level=3)
)
