;
; parse-disjuncts.scm -- Demo of getting the disjuncts used in a parse.
;
; The Link Grammar parser will parse natural language sentences,
; returning a dependency graph of how the words are connected.
; The Atomese API for the LG parser converts that graph into
; Atomese format. This format is quite verbose, and some applications
; do not need the full parse information. This demo illustrates how
; to get the disjuncts, only, without the rest of the parse info.
; -----------------------------------------------------------------

; Load the guile modules
(use-modules (opencog) (opencog exec))
(use-modules (opencog nlp) (opencog nlp lg-parse))

(use-modules (srfi srfi-1))

; Parse an example sentence
(cog-execute!
	(LgParseDisjuncts    ; There is also a "full" parse, demoed elsewhere.
		(PhraseNode "this is a test.")   ; The example sentence
		(LgDictNode "en")  ; The dictionary to use - English in this case.
		(NumberNode 1)))   ; The number of parses to perform.

; To see the parse in it's full glory, it's easiest to just print
; the entire contents of the AtomSpace.
(cog-prt-atomspace)

; Look for disjuncts, for example, you should see something like
;
;    (LgWordCset
;      (WordInstanceNode "What@ec45f2db-a013-47c9-bde6-39b043d4a54a")
;      (LgAnd
;        (LgConnector
;          (LgConnNode "Wn")
;          (LgConnDirNode "-"))
;        (LgConnector
;          (LgConnNode "O")
;          (LgConnDirNode "+"))))
;
; which says that the word `What` had the disjunct `Wn- & O+` on it.
;

; ---------------------
; That's all, folks!
