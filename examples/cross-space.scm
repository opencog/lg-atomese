;
; cross-space.scm -- Demo of using an AtomSpace-backed dictionary.
;
; The Link Grammar parser can use dictionary data obtained from an
; AtomSpace. This is typically needed when the dictionary is the
; result of unsupervised grammar learning; specifically, the project
; in the https://github.com/opencog/learn git repo.
;
; That project stores the dictionary in a format that is similar to,
; but is distinctly different from the strict LG-compatible format.
; Thus, there is a need to be able to correlate the AtomSpace
; dictionary to the parse results.  This demo shows how to do this.
;
; See the `parse-disjuncts.scm` demo as a pre-requisite.
; -----------------------------------------------------------------

; Load the guile modules
(use-modules (opencog) (opencog exec))
(use-modules (opencog nlp) (opencog nlp lg-parse))
(use-modules (opencog persist) (opencog persist-file))

; Specify a location of a dictionary, and open it.
(define fsn
	(FileStorage "/usr/local/share/link-grammar/demo-atomese/atomese-dict.scm"))
(cog-open fsn)

; Set up a parse node. The arguments are as follows:
;
; The demo dictionary (above) can parse only one sentence: "level
; playing field".  Don't change this, else the parse will fail.
;
; The (LgDictNode "demo-atomese") specifies an LG configuration file
; that LG will recognize as being AtomSpace-backed. An invalid
; specification will throw an error.
;
; The (NumberNode 4) specifies how many linkages to return.
;
; The (cog-atomspace) specifies the AtomSpace that contains the
; dictionary. In this case, it will be the current dictionary.
; This argument is optional; if it is absent, then the correlating
; EvaluationLinks (shown below) will not be written into the curretnt
; AtomSpace. The demo still works, but a key bit of info will be
; missing.
;
; The fsn specifies the StorageNode containing the dictionary.
; This argument is optional; if it is absent, the entire dictionary
; MUST be present in the prior AtomSpace argument.  If the AtomSpace
; argument is also missing, then the LG dictionary config (specified
; in the LgDictNode) will be used.
;
(define pda
	(LgParseDisjuncts
		(PhraseNode "level playing field")
		(LgDictNode "demo-atomese")
		(NumberNode 4)
      (cog-atomspace)
      fsn))

; Parse the example sentence.
(cog-execute! pda)

; To result will place EvaluationLinks matching up the parse results
; with the dictionary contents.  Look at the entire contents of the
; AtomSpace to get a clear idea:
(cog-prt-atomspace)

; One of the links will look like this:
;
;   (EvaluationLink
;      (PredicateNode "*-LG connector string-*")
;      (LgConnNode "C")
;      (SetLink
;        (WordNode "playing")
;        (WordNode "field")))
;   
; This states that the LG connector "C" used in the parse corresponds to
; the word-pair playing-field in the AtomSpace dictionary. If this seems
; unclear, take a good look at the dictionary.  Gram classes look
; similar, but different.
;
; ---------------------
; That's all, folks!
