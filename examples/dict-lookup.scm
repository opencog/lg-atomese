;
; dict-lookup.scm -- look up a word in a dictionary.
;
; Link Grammar specifies natural languages in terms of a dictionary of
; words, with each dictionary entry describing all of the ways in which
; a word can link up to other nearby words. Direct access to that
; dictionary can be useful; this demo shows how to look up the
; dictionary entries for individual words.
;--------------------------------------------------------------------

; Load the guile modules
(use-modules (opencog) (opencog exec))
(use-modules (opencog nlp) (opencog nlp lg-dict))

; Look up a word in a dictionary. Both the word and the dictionary
; must be supplied. By default, the dictionary used is the standard
; LG text dictionary, installed in the /usr/local directory.
; An AtomSpace can also be used to provide a dictionary; see the
; `cross-space.scm` demo.
(cog-execute! (LgDictEntry (Word "yikes") (LgDictNode "en")))

; Documentation can be found at
;    https://wiki.opencog.org/w/LgDictNode

; -----------
; Here's an example of a lookup in the Russian dictionary:
(cog-execute! (LgDictEntry (Word "доктор") (LgDictNode "ru")))

; Note that Russian has a complex morphology, and this is reflected
; in the much larger dictionary entries.

; -----------
; The `(opencog nlp lg-dict)` provides a number of useful utilities and
; tools.

; Is a word in a dictionary? Returns true or false:
(cog-execute! (LgHaveDictEntry (Word "доктор") (LgDictNode "ru")))
(cog-execute! (LgHaveDictEntry (Word "дasdf") (LgDictNode "ru")))

; Two deprecated utility functions are shown below. Thyese should not
; be used in new code. It these are really actually needed, then a new
; Link type should be created for each, such that executing that Link
; performs the functions below.
;
; lg-conn-type-match?
; lg-conn-linkable?
;
; You can get documentation for each with the ,d or ,describe command
; at the guile prompt. For example:
,d lg-conn-linkable?

; Lets try this out:
(lg-conn-linkable?
	(LgConnector (LgConn "Ss") (LgConnDir "+"))
	(LgConnector (LgConn "S") (LgConnDir "-")))

; The above returns true, because Ss+ can link to S-.
; Try the above again, with Ss+ and S+  -- these are not linkable.
; Nor is Ss+ and Sp-, and so on.

; The `lg-conn-type-match?` function does the same, but ignores the
; direction (does not do direction matching):
(lg-conn-type-match?
	(LgConnector (LgConn "Ss") (LgConnDir "+"))
	(LgConnector (LgConn "S") (LgConnDir "+")))

; -------------
; That's all, folks!
