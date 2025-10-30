
Link Grammar Atomese Bindings
=============================

This directory contains Atomese for the Link Grammar dictionary and
parsing library.


lg-dict
-------
Import Link Grammar dictionary entries into the AtomSpace. Allows
different dictionaries to be opened, and words to be looked up in them.
Implements the `LgDictEntry` and the `LgHaveDictEntry` atoms.

lg-parse
--------
Parse sentences and return them wrapped in a LinkValue. Implements
the `LgParse`, `LgParseBonds`, `LgParseSections` and `LgParseDisjuncts`
Atoms.

scm
---
The scm directory defines the `(opencog lg)` guile module.  This module
provides basic type definitions.

types
-----
Definition of assorted natural-language-processing Atom Types. These
are used by many different OpenCog NLP subsystems.
