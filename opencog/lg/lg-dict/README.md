# LG-Dict

Modules and functions for generating a LG dictionary entry of a word
in the AtomSpace.

## Scheme module `(opencog lg)`

Defines `LgDictNode`, `LgDictEntry` and `LgHaveDictEntry`.  These can
be used to look up Link Grammar dictionary entries, and generate an
Atomese expression for them, returning that expression.

```
	(use-modules (opencog) (opencog lg))
	(use-modules (opencog exec))
	(cog-execute!
		(LgDictEntry
			(WordNode "...")
			(LgDictNode "en")))
```
will look up the word "..." in the English language Link Grammar
dictionary, and return a LinkValue of expressions of the form.
```
   (LgDisjunct
      (LgConnector
         (LgConnNode "Sp")
         (LgConnDirNode "-"))
      (LgConnector
         (LgConnNode "dWV")
         (LgConnDirNode "-")))
```

Because the above is quite verbose, there is a fast, high-speed way
for checking to see if a dictionary entry exists in the dictionary,
without loading it: the is the `LgHaveDictEntry` link. It has the
same syntax as `LgDictEntry` except that it will return either true of false:
```
	(cog-execute!
		(LgHaveDictEntry
			(WordNode "blorgel-bargel")
			(LgDictNode "en")))
```

The term "disjunct" arises because the connectors are listed in
[Disjunctive Normal Form](http://en.wikipedia.org/wiki/Disjunctive_normal_form) (DNF).

Each LG connector is fully described within the `LgConnector` link,
with the connector name in `LgConnNode`, direction in `LgConnDirNode`,
and the multi-connect property in `LgConnMultiNode`.

The connector ordering is kept intact. Connectors and their meaning and
usage are described in the [Link Grammar documentation](http://www.abisource.com/projects/link-grammar/dict/introduction.html),
section 1.2.1.

For more information on the Node & Link, see `lg/types/atom_types.script`

**Since the disjuncts are in DNF, for some words there will be an explosion
of atoms creation (for example, up to 9000 disjuncts for a word, each
disjunct containing 5+ connectors).**


In addition, the following scheme utilities are provided:
- `(lg-conn-type-match? (LgConnector ...) (LgConnector ...))`

  Takes two `LgConnector` links as input, and check if the two connectors has
  the same type (aka. connector name).  Proper handling of subscripts &
  head/tail are included.

  The same code could have been done purely in scheme, for historical reasons.
  Use of this function is deprecated.

- `(lg-conn-linkable? (LgConnector ...) (LgConnector ...))`

  Takes two `LgConnector` links as input, and check if the two connectors can
  be linked.  Two connectors can be linked only if they are of different
  direction, and their types match.

  This function does not care which connector is "-" and which is "+", as long
  as they are different.

  Use of this function is deprecated. If it is really needed, a new
  Atom should be created that implements this.

## TODO - Architecture and design issues.
The core design of this module has a number of issues, some minor, and
some pretty important.

* Handling of optional links is currently broken.

* The LgDictEntry fails to perform regex lookup of the word.
  Properly, this is a bug in the link-grammar API for word lookup;
  regexes should have been handled automatically.
  This will take a few afternoons to fix.

* The LgDictEntry does the wrong thing, or does invalid/inappropriate
  things, if the word has a non-trivial morphology
  (i.e. can be split into multiple morphemes). In LG, each morpheme
  is treated as a "word", and so a single word-string can be split
  in several different ways (i.e. have multiple splittings).  Word
  splitting is non-trivial in LG.

  One way to fix this last issue is to have LG provide an API where
  the word is split into morphemes, and then the morphemes are
  recombined, and disjuncts are returned for the recombined splits.
  That is, the morphology can be hidden "under the covers", which is
  part of the beauty of the disjunct style.

  Right now, this is low priority, since only Russian currently has a
  non-trivial morphology, and we don't handle Russian.

* The format of the word-disjunct association in the AtomSpace does not
  indicate which dictionary the disjuncts came from. This prevents
  multi-dictionary use, because its not clear which disjuncts came from
  which dictionary. This makes multi-language operation impossible.
