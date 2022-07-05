;
; network-client.scm
;
; The client side of a client-server implementation for Link Grammar
; parsing. This uses the CogStorageNode to open a network connection
; to the parse server. All of the parsing is done on the server; the
; results of the parse are shiped over the network to the local host.
;
(use-modules (opencog) (opencog exec))
(use-modules (opencog persist))
(use-modules (opencog persist-cog))
(use-modules (opencog nlp))
(use-modules (opencog nlp lg-dict))
(use-modules (opencog nlp lg-parse))

; Define a StorageNode that will connect to the remote server.
(define csn (CogStorageNode "cog://localhost:17003"))

; Open the network connection
(cog-open csn)

; Define the parse that will be performed on the server.
(define qry
	(LgParseDisjuncts
		(PhraseNode "this is a test.")
		(LgDictNode "en")
		(NumberNode 1)))

; Define where the perse results will be located.
(define anchor (Predicate "result anchor"))

; Perform the remote parsing...
(fetch-query qry anchor)

; ... and view the results.
(cog-value qry anchor)

; Take a look at everything in the local atomspace.
(cog-prt-atomspace)

; ----------------------------------------------------
; How about dict entries?
; The API is a bit diffferent here, than above.

(define lookup (LgDictEntry (Word "yikes") (LgDictNode "en")))
(fetch-query lookup anchor)
(fetch-incoming-by-type (Word "yikes") 'LgDisjunct)
(cog-incoming-by-type (Word "yikes") 'LgDisjunct)

; Close the network connection
(cog-close csn)
