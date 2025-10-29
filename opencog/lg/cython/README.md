Python bindings for Link Grammar Atomese
----------------------------------------

## Requirements ##

* Python 3.4 or newer.
* Cython 0.14 or later. http://www.cython.org/
* Nosetests - for running unit tests.

Both Cython and Nosetests can be installed with easy_install:

 sudo easy_install cython nose

The bindings are written mostly using Cython, which allows writing
code that looks pythonic but gets compiled to C.  It also makes it
trivial to access both Python objects and C objects without using a
bunch of extra Python library API calls.

Currently the package structure looks like this:

 opencog.nlp

## Tutorial ##

The OpenCog wiki contains the Python tutorial:

http://wiki.opencog.org/w/Python
