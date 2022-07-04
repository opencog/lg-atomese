Atomese API for Link Grammar
============================

[![CircleCI](https://circleci.com/gh/opencog/lg-atomese.svg?style=svg)](https://circleci.com/gh/opencog/lg-atomese)

This repo provides an Atomese API for
[Link Grammar](https://github.com/opencog/link-grammar), allowing Link
Grammar dictionaries and parse results to be accessed from the
AtomSpace.

Status
------
### Version 1.0
The code here has been used in production for many years.

However, there are still some things that would be nice to have.
This includes:
* Placing costs on the parse results.
* Reporting costs in dictionary lookups.

Prerequisites
-------------
The following packages must first be built and installed.

###### cogutil
> Common OpenCog C++ utilities
> https://github.com/opencog/cogutil
> It uses exactly the same build procedure as this package. Be sure
  to `sudo make install` at the end.

###### atomspace
> OpenCog Atomspace database and reasoning engine
> https://github.com/opencog/atomspace
> It uses exactly the same build procedure as this package. Be sure
  to `sudo make install` at the end.

###### Link Grammar
> Natural Language Parser for English, Russian, other languages.
> https://www.abisource.com/projects/link-grammar/


Building LG-Atomese
-------------------
Perform the following steps at the shell prompt:
```
    cd to project root dir
    mkdir build
    cd build
    cmake ..
    make
    sudo make install
```
Libraries will be built into subdirectories within build, mirroring
the structure of the source directory root.


Unit tests
----------
To build and run the unit tests, from the `./build` directory enter
(after building opencog as above):
```
    make test
```

At this time, there are no unit tests.

Examples
--------
See the [`examples`](./examples) directory for examples of how to use
this Atomese API to Link Grammar.
