;
; parse.scm -- Demonstration of parsing sentences with Link Grammar.
;
; The Link Grammar parser will parse natural language sentences,
; returning a dependency graph of how the words are connected.
; The Atomese API for the LG parser converts that graph into
; Atomese format. This format is quite verbose, and so most
; of this demo is an examination of that format.
; -----------------------------------------------------------------

; Load the guile modules
(use-modules (opencog) (opencog exec))
(use-modules (opencog nlp) (opencog nlp lg-parse))

; Parse an example sentence
(cog-execute!
	(LgParseMinimal    ; There is also a "full" parse, demoed below.
		(PhraseNode "this is a test.")   ; The example sentence
		(LgDictNode "en")  ; The dictionary to use - English in this case.
		(NumberNode 1)))   ; The number of parses to perform.

; The above will return an identifier - an anchor point - from which
; the entire parse can be traced.  It will return something like
; (SentenceNode "sentence@0c84adfa-babd-4b71-9d3a-51dfb3352e1e")

; To see the parse in it's full glory, it's easiest to just print
; the entire contents of the AtomSpace.
(cog-prt-atomspace)
