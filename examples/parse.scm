;
; parse.scm -- Demo showing the different kinds of available parse info.
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

; All of the examples below parse the same sentence. The ASCII-graphics
; representation, as printed by link-parser, is this:
;
;      linkparser> This is a test.
;      Found 8 linkages (8 had no P.P. violations)
;         Linkage 1, cost vector = (UNUSED=0 DIS= 0.00 LEN=6)
;
;          +-------------Xp------------+
;          +----->WV----->+---Osm--+   |
;          +-->Wd---+-Ss*b+  +Ds**c+   |
;          |        |     |  |     |   |
;      LEFT-WALL this.p is.v a  test.n .
;
;      Press RETURN for the next linkage.
;
; This diagram should be compared to the outputs given below.
;
; -----------------------------------------------------------------
; Parse an example sentence, returning the bonds (links) between words.
;
(cog-execute!
	(LgParseBonds        ; Parse, but return only the links (bonds).
		(PhraseNode "this is a test.")   ; The example sentence
		(LgDictNode "en")  ; The dictionary to use - English in this case.
		(NumberNode 1)))   ; The number of parses to perform.

; The bonds (links) can be read off from the ASCII-graphics chart above.
; In Atomese, the Bonds include these:
;
;      (Edge
;        (Bond "Ss*b")      ; The subject link
;        (List
;          (Word "this")
;          (Word "is")))
;      (Edge
;        (Bond "Osm")       ; The object link
;        (List
;          (Word "is")
;          (Word "test")))
;      (Edge
;        (Bond "Ds**c")     ; The determiner link
;        (List
;          (Word "a")
;          (Word "test")))
;

; -----------------------------------------------------------------
; Same as above, but return the disjuncts that were selected for
; the parse.
;
(cog-execute!
	(LgParseDisjuncts
		(PhraseNode "this is a test.")
		(LgDictNode "en")
		(NumberNode 1)))

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
; This format does NOT include any info about which connectors connected
; to which other connectors. In principle, this can be deduced by the fact
; that LG parses are always planar, and so there are no link-crossings.
; Alternately, LgParseBinds returns this info directly.

; -----------------------------------------------------------------
; Same as above, but return the disjuncts, represented as Sections.
;
(cog-execute!
	(LgParseSections
		(PhraseNode "this is a test.")
		(LgDictNode "en")
		(NumberNode 1)))

; One of the sections will look like this:
;
;      (Section
;        (Word "this")
;        (ConnectorSeq
;          (Connector
;            (Word "###LEFT-WALL###")
;            (Sex "-"))
;          (Connector
;            (Word "is")
;            (Sex "+"))))
;
; Comparing this to the disjunct representation, the same connectivity
; pattern is reported, except that each LgConnector is replaced by the
; target link word.
;
; The type of the connection is not reported. The type of the connection
; can be thought of as a classification: the word-pair (this,is) belongs
; to the bond class "Ss*b". It is an instance in that class. The
; classification is not unique; the word pair (this,is) may obtain other
; bond-class assignments, depending on the parse of the sentence as a
; whole.
;
; ---------------------
; That's all, folks!
