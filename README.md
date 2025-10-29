Atomese API for Link Grammar
============================

[![CircleCI](https://circleci.com/gh/opencog/lg-atomese.svg?style=svg)](https://circleci.com/gh/opencog/lg-atomese)

This repo provides an
[Atomese API](https://wiki.opencog.org/w/Atomese)
for
[Link Grammar](https://github.com/opencog/link-grammar), allowing Link
Grammar dictionaries and parse results to be accessed from the
AtomSpace.

Link Grammar has its roots in Natural Language Processing, but appears
to be more general, and seems capable of assigning structural
relationships to items in arbitrary configurations. That is, not just
words in sentences, but linear streams, and even non-planar relationship
graphs. That is, it is a kind of "graph parser". Exactly where the
theoretical limits are is unclear; its usage in a general setting
continues to be explored, as of 2025.

Traditional LG worked with language description files, aka
"dictionaries" providing the "lexis" from which parsing is done.
The original natural language dictionaries were created by hand.
Current versions of Link Grammar can pull dictionary entries out
of the AtomSpace, thus allowing the dictionary to be maintained
dynamically, using learning algorithms of any desired sort.
In particular, learning and parsing can be interleaved, sentence
by sentence, instead of considned to batch processing.


Status
------
### Version 2.0
The code here has been used in production for many years.
Version 2.0 removes several older formats that were provided
in version 1.0. See the documentation for details:

* [LgParseLink](https://wiki.opencog.org/w/LgParseLink)
* [LgParseBonds](https://wiki.opencog.org/w/LgParseBonds)
* [LgParseDisjuncts](https://wiki.opencog.org/w/LgParseDisjuncts)
* [LgParseSections](https://wiki.opencog.org/w/LgParseSections)
* [LgDictEntry](https://wiki.opencog.org/w/LgDictEntry)
* [LgConnExpand](https://wiki.opencog.org/w/LgConnExpand)

However, there are still some things that would be nice to have.
This includes:
* Placing costs (aka entrpy) on the parse results.
* Reporting costs (aka entropy) in dictionary lookups.

Prerequisites
-------------
The following packages must first be built and installed.

###### cogutil
* Common OpenCog C++ utilities
* https://github.com/opencog/cogutil
* It uses exactly the same build procedure as this package. Be sure
  to `sudo make install` at the end.

###### atomspace
* OpenCog Atomspace hypergraph database
* https://github.com/opencog/atomspace
* It uses exactly the same build procedure as this package. Be sure
  to `sudo make install` at the end.

###### atomspace-storage
* OpenCog Atomspace Storage subsystem
* https://github.com/opencog/atomspace-storage
* It uses exactly the same build procedure as this package. Be sure
  to `sudo make install` at the end.

###### Link Grammar
* Natural Language Parser for English, Russian, other languages.
* https://opencog.github.io/link-grammar-website/
* Git repo:  https://github.com/opencog/link-grammar
* This uses the autoconf toolset. When building from the tarball,
  say `mkdir build; cd build; ..configure; make -j; sudo make install`
  When building from the git repo, you must first say
  `./autogen.sh --no-configure`. There are various prereqs to install,
  first, including autotools, autotools-archive, libpcre-dev, aspell,
  and libeditline-dev


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
    make check
```

Examples
--------
See the [`examples`](./examples) directory for examples of how to use
this Atomese API to Link Grammar. There are three basic functions
provided:
* Parsing sentences to get links (bonds), disjuncts and sections.
* Looking up words in a dictionary to get disjunt choices.
* Analyzing connectors, expanding them into types and subtypes.

---
