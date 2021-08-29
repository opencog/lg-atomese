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

(use-modules (srfi srfi-1))

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

; Documentation for how the parse is represented in Atomese can
; be found in the wiki:
;     https://wiki.opencog.org/w/Sentence_representation
; and the node itself is documented at
;     https://wiki.opencog.org/w/LgParseLink

; ---------------------
; Some examples of crawling over the parse graph.

; First, put the sentence node where we can get at it easily.
; (define sent (SentenceNode "sentence@0c84adfa-babd-4b71-9d3a-51dfb3352e1e"))

; Get all of the parses associated with this sentence.
(define (get-parses SENT)
	(cog-execute! (Meet (Present (Parse (Variable "?parse") SENT)))))

; Just print all of them (there should be only one, since we asked
; for only one.)
(get-parses sent)

; ---------------------
; Give a short name to the first parse.
(define pars (first (cog-value->list (get-parses sent))))

; Get all the word instances in the parse.
(define (get-word-instances PARS)
	(cog-execute! (Meet (Present (WordInstance (Variable "?wrd") PARS)))))

(get-word-instances pars)

; ---------------------
; A word may occur two or more times in a sentence, and thus, the word
; instance is a label indicating which word it is. The raw words can be
; gotten like so:

(define (get-words PARS)
	(define qry
		(Query
			(VariableList (Variable "?winst") (Variable "?wrd"))
			(Present
				(WordInstance (Variable "?winst") PARS)
				(Reference (Variable "?winst") (Variable "?wrd")))
			(Variable "?wrd")))

	(cog-execute! qry))

(get-words pars)

; ---------------------
; The above is listed in arbitrary order. The below converts the
; Atomese graph holding the word sequence into a collection of
; scheme pairs.  This is nothing other than a format change:
; it's still the same graph, but represented in Scheme, rather
; than Atomese.

(define (get-word-seq PARS)
	(define qry
		(Query
			(VariableList
				(Variable "?winst")
				(Variable "?wrd")
				(Variable "?wseq"))
			(Present
				(WordInstance (Variable "?winst") PARS)
				(WordSequence (Variable "?winst") (Variable "?wseq"))
				(Reference (Variable "?winst") (Variable "?wrd")))
			(List (Variable "?wseq") (Variable "?wrd"))))

	; Run the query. This returns a QueueValue.
	(define qwords (cog-execute! qry))

	; Convert the QueueValue to a scheme list.
	(define wds (cog-value->list qwords))

	; Convert the list of Atoms to scheme pairs.
	(map
		(lambda (APAIR)
			(cons
				(cog-name (cog-value-ref APAIR 0))
				(cog-name (cog-value-ref APAIR 1))))
		wds)
)

(get-word-seq pars)

; ---------------------
; Last but not least, get all of the linkages in the parse.

(define (get-links PARS)
	(define qry
		(Query
			(VariableList
				(TypedVariable (Variable "?winst") (Type 'WordInstanceNode))
				(TypedVariable (Variable "?wi2") (Type 'WordInstanceNode))
				(TypedVariable (Variable "?lnk") (Type 'LgLinkNode)))
			(Present
				(WordInstance (Variable "?winst") PARS)
				(Evaluation
					(Variable "?lnk")
					(List (Variable "?winst") (Variable "?wi2"))))

			; Just echo the evaluation link.
			(Evaluation
					(Variable "?lnk")
					(List (Variable "?winst") (Variable "?wi2")))))

	(cog-execute! qry))

(get-links pars)

; ---------------------
; The LgParseMinimal returns just enough information to reconstruct
; the parse. In some cases, it is useful to know the disjuncts
; that appeared in the parse, or the explicit linkages of connectors.
; For this, use `LGParse` instead of `LgParseMinimal`.  Minimal is
; nice, in that it does not clutter up the AtomSpace with the disjuncts,
; if they are not wanted.
(cog-execute!
	(LgParse
		(PhraseNode "What a deal!")
		(LgDictNode "en")
		(NumberNode 1)))

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
; Similarly, the words `What` and `deal` were connected with an `Os`
; link, which was obtained by joining the `O+` connector to `Os-`:
;
;    (LgLinkInstanceLink
;      (LgLinkInstanceNode "Os@sentence@5e069301-51de-484e-92ed-e8533de7ba40_parse_0-link-2")
;      (LgConnector
;        (LgConnNode "O")
;        (LgConnDirNode "+"))
;      (LgConnector
;        (LgConnNode "Os")
;        (LgConnDirNode "-")))
;
; The LinkInstance is an instance of a specific link:
;
;    (ReferenceLink
;      (LgLinkInstanceNode "Os@sentence@5e069301-51de-484e-92ed-e8533de7ba40_parse_0-link-2")
;      (LgLinkNode "Os"))
;
; The LinkInstance joints two specific words together:
;
;    (EvaluationLink
;      (LgLinkInstanceNode "Os@sentence@5e069301-51de-484e-92ed-e8533de7ba40_parse_0-link-2")
;      (ListLink
;        (WordInstanceNode "What@ec45f2db-a013-47c9-bde6-39b043d4a54a")
;        (WordInstanceNode "deal@2628c310-bff2-4ec4-826d-f1d6b49d657f")))
;
; Note that the above is very much like the earlier form:
;
;    (EvaluationLink
;      (LgLinkNode "Os")
;      (ListLink
;        (WordInstanceNode "What@ec45f2db-a013-47c9-bde6-39b043d4a54a")
;        (WordInstanceNode "deal@2628c310-bff2-4ec4-826d-f1d6b49d657f")))
;
; except that the link instance is unambiguously identified.

; ---------------------
; That's all, folks!
