
Link Grammar parsing
====================

Perform a Link Grammar parse of a sentence, and insert the results into
the AtomSpace.  This was designed to be compatible with the LG subset of
the RelEx parse. As of 2022, RelEx is obsolete and no longer supported.

LgParseLink
-----------
Parsing is performed by calling the `execute()` method on the C++ class
LgParseLink, or equivalently, calling the scheme function `cog-execute!`
on it.  The LgParseLink is a kind of FunctionLink, and can thus be used
in any expression that FunctionLinks can be used with. For example, it
can be used (with variables) within BindLinks and PutLinks.

The expected format of an LgParseLink is:

    LgParseLink
        PhraseNode "this is a test."
        LgDictNode "en"
        NumberNode  6   -- optional, number of parses.
        AtomSpace  foo  -- optional, AtomSpace holdig dict info.
        StorageNode bar -- optional, StorageNode holding dict info.

When executed, the result of parsing the phrase text, using the
specified dictionary, is placed in the atomspace.  Execution
returns a SentenceNode pointing at the parse results.  If the third,
optional NumberNode is present, then that will be the number of
parses that are captured. If the NumberNode is not present, it
defaults to four.

If the `LgDictNode` specified an AtomSpace-backed dictionary, and
the fourth argument is present, then the dictionary word lookups
will be performed from the specified AtomSpace.  Note that
`EvaluationLink`s will be created in that AtomSpace, tying together
the LG connector types to the AtomSpace connector types. This is
the only reason for specifying an AtomSpace: to get back that info.

If the `LgDictNode` specified an AtomSpace-backed dictionary, and
the fifth argument is present, then the dictionary word lookups
will be performed from the specified `StorageNode`. Otherwise, if
an AtomSpace is specified, but the `StorageNode` is not, the parser
will use the AtomSpace contents only; the entire dictionary must
be present in the AtomSpace.

LgParseMinimal
--------------
This performs the same parse as `LgParseLink`; however, it does not
insert the resulting disjuncts into the AtomSpace. As the disjuncts
are quite verbose, this significantly reduces the number of atoms
placed in the AtomSpace.

LgParseDisjuncts
----------------
This performs the same parse as `LgParseLink`; however, it does not
insert the resulting word instances and linkages into the AtomSpace;
instead, it ONLY inserts the disjuncts.  As the linkages are quite
verbose, this significantly reduces the number of atoms placed in
the AtomSpace.

Example
-------
Here's a working example:
```
(use-modules (opencog) (opencog nlp) (opencog nlp lg-parse) (opencog exec))
(cog-execute! (LgParseLink  (PhraseNode "this is a test.")
    (LgDictNode "en") (NumberNode 1)))
(cog-prt-atomspace)
```

More examples can be found in the top-level
[`examples`](../../../examples) directory.

Notes
-----
This is a minimalist API to the Link Grammar parser, attempting to
live off the default options that Link Grammar provides.  At this time,
it is not envisioned that there will ever be any need to expand beyond
this minimalist API.

Pros and Cons
-------------
Since this provides a format compatible with the RelEx parse server,
this means that there are two ways of getting parsed text into the
atomspace: using this link, or using the RelEx server.  There are
competing pros and cons of doing it each way:

* The RelEx server is obsolete. It still works, but there no support
  for it any more. No bug-fixes, no active development.

* The RelEx server is a network server, and can be run on any
  network-connected machine.

* If you want to have a networked LG parser server, you can do this
  with the `CogStoraeNode`. See the examples directory.

* The RelEx server generates scheme strings, which must be parsed by
  the scheme interpreter in OpenCog. This adds a lot of overhead, and
  can be slow. Guile memory management gets unhappy, when fed too many
  long strings.

* The RelEx server supports a much larger set of LG options, and can
  thus be made to do unusual things, should you need unusual things.
