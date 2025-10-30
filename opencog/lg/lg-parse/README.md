
Link Grammar parsing
====================

Perform a Link Grammar parse of a sentence, returning the results in various
formats.

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

LgParseBonds
------------
https://wiki.opencog.org/w/LgParseBonds

This returns a LinkValue holding the different parses; each parse is a
LinkValue for the links (bonds) in that parse.

LgParseDisjuncts
----------------
https://wiki.opencog.org/w/LgParseDisjuncts

This returns a LinkValue holding the different parses; each parse is a
LinkValue for the disjuncts in that parse, in sequence.

LgParseSections
---------------
https://wiki.opencog.org/w/LgParseSections

Same as above, but creates Sections instead of disjuncts.

Example
-------
Here's a working example:
```
(use-modules (opencog) (opencog lg) (opencog exec))
(cog-execute! (LgParseBonds  (PhraseNode "this is a test.")
    (LgDictNode "en") (NumberNode 1)))
```

More examples can be found in the top-level
[`examples`](../../../examples) directory.

Notes
-----
This is a minimalist API to the Link Grammar parser, attempting to
live off the default options that Link Grammar provides.  At this time,
it is not envisioned that there will ever be any need to expand beyond
this minimalist API.
