
Link Grammar Atomese Bindings
=============================

This directory contains Atomese for the Link Grammar dictionary and
parsing library.


lg-dict
-------
Import Link Grammar dictionary entries into the AtomSpace. Allows
different dictionaries to be opened, and words to be looked up in them.
A lookup loads all of the LG disjuncts for that word into the atomspace. 
Implements the `LgDictEntry` and the `LgHaveDictEntry` atoms.

lg-parse
--------
Parse sentences and place parse results into the AtomSpace. Implements
the `LgParse`, `LgParseMinimal` and `LgParseDisjuncts` Atoms.

A parsed sentence consists of zero or more parses. Each parse consists
of a sequence of `WordInstanceNode`, together with a listing of the 
LG Links connecting those words. The `LgParseMinimal` link does less
work, by skipping the creation of the disjuncts. The `LgParseDisjuncts`
link does less work by creating *only* the disjuncts, and none of the
rest of the linkage info.

scm
---
The scm directory defines the `(opencog nlp)` guile module. It has this
name (instead of `(opencog lg-atomese)`) in order to preserve backwards
compatibility with older code. This module provides basic type
defintions, and assorted scripts for pulling out bits and pieces of
LG markup from a parsed sentence.

types
-----
Definition of assorted natural-language-processing Atom Types. These
are used by many different OpenCog NLP subsystems.
