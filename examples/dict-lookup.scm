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
(use-modules (opencog) (opencog nlp))
