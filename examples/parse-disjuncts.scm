;
; parse-disjuncts.scm -- Demo of getting the disjuncts used in a parse.
;
; The Link Grammar parser will parse natural language sentences,
; returning a dependency graph of how the words are connected.
; There are multiple ways to think about the resulting parse:
; -- As a collection of bonds between word pairs (LgParseBond)
; -- As a collection of disjuncts, one per word, chosen for the parse/
; -- As a collection of sections, one per word, showing connections.
;
; -----------------------------------------------------------------

; Load the guile modules
(use-modules (opencog) (opencog exec))
(use-modules (opencog nlp) (opencog nlp lg-parse))

; Parse an example sentence
(cog-execute!
	(LgParseDisjuncts    ; Parse, but return only the disjuncts.
		(PhraseNode "this is a test.")   ; The example sentence
		(LgDictNode "en")  ; The dictionary to use - English in this case.
		(NumberNode 1)))   ; The number of parses to perform.

; One of the disjuncts will look like this:
;
;    (LgDisjunct
;      (WordNode "this")
;      (LgAnd
;        (LgConnector
;          (LgConnNode "Wd")
;          (LgConnDirNode "-"))
;        (LgConnector
;          (LgConnNode "Ss*b")
;          (LgConnDirNode "+"))))
;
; which says that the word `this` had the disjunct `Wd- & Ss*b+` on it.
;
; Note that this format does NOT include any info about which
; word-instance this was in the sentence, nor which words the
; connectors connected to. That info is available by using the
; `LgParseLink` parser.

; ---------------------
; That's all, folks!
