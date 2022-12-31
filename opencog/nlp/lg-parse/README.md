
Link Grammar parsing
====================

Perform a Link Grammar parse of a sentence, and insert the results into
the AtomSpace.  Two of the provided functions were designed to be
compatible with the LG subset of the RelEx parse. Two others are more
modern and easier to use. As of 2018, RelEx is obsolete and no longer
supported, and so this provides a suitable upgrade path for that format.

Full documentation for the output format is here:
https://wiki.opencog.org/w/Sentence_representation

LgParseLink
-----------
https://wiki.opencog.org/w/LgParseLink

Parsing is performed by calling the `execute()` method on the C++ class
LgParseLink, or equivalently, calling the scheme function `cog-execute!`
on it.  The LgParseLink is a kind of FunctionLink, and can thus be used
in any expression that FunctionLinks can be used with. For example, it
can be used (with variables) within BindLinks and PutLinks.

The expected format of an LgParseLink is:

    LgParseLink
        PhraseNode "this is a test."
        LgDictNode "en" -- or any other valid dictionary name.
        NumberNode  6   -- optional, number of parses.
        AtomSpace  foo  -- optional, AtomSpace holding dict info.
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

The format is documented at https://

LgParseMinimal
--------------
https://wiki.opencog.org/w/LgParseMinimal

This performs the same parse as `LgParseLink`; however, it does not
insert the resulting disjuncts into the AtomSpace. As the disjuncts
are quite verbose, this significantly reduces the number of atoms
placed in the AtomSpace.

LgParseDisjuncts
----------------
https://wiki.opencog.org/w/LgParseDisjuncts

This returns a LinkValue holding the different parses; each parse is a
LinkValue for the disjuncts in that parse, in sequence. This has the
advantage of being easier to use than the rather clunky RelEx format.
Also, it avoids the creation of WordInstances, and thus significantly
reduces the number of atoms placed in the AtomSpace.

LgParseSections
---------------
https://wiki.opencog.org/w/LgParseSections

Same as above, but creates Sections instead of disjuncts.

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

RelEx Compatibility
-------------------
The LgParse and LgParseMinimal formats are backwards-compatible with
the RelEx system. The other formats are not; they're more modern and
easier to use.

Since the provided format is compatible with the RelEx parse server,
this means that there are two ways of getting parsed text into the
AtomSpace: using these two links, or using the RelEx server.  There are
competing pros and cons of doing it each way:

* The RelEx server is obsolete. It still works, but there no support
  for it any more. No bug-fixes, no active development.

* The RelEx server is a network server, and can be run on any
  network-connected machine.

* If you want to have a networked LG parser server, you can do this
  with the `CogStorageNode`. See the examples directory.

* The RelEx server generates scheme strings, which must be parsed by
  the scheme interpreter in OpenCog. This adds a lot of overhead, and
  can be slow. Guile memory management gets unhappy, when fed too many
  long strings.

* The RelEx server supports a much larger set of LG options, and can
  thus be made to do unusual things, should you need unusual things.
