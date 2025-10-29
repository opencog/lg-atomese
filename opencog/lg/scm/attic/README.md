Obsolete code
-------------
For reference purposes only. Do not use. It's dead. Do not revive.

The following scheme utilities are now gone:
- `(lg-dict-entry (WordNode "..."))`

  Wraps up the above-described `(cog-execute (LgDictEntry ...))` into
  a nice short convenience utility.

- `(lg-get-dict-entry (WordNode "..."))`

  Identical to calling `(SetLink (lg-dict-entry (WordNode "...")))`
  Deprecated!  Using the SetLink in this fashion causes a number of
  problems; SetLinks should not be used as dumping grounds for random
  assortments of atoms!
