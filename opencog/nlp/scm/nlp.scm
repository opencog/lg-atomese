(use-modules (opencog))

(define-module (opencog nlp)
	#:use-module (opencog)
	#:use-module (opencog lg-config)
)

; Load the C library; this calls the nameserver to load the types.
(load-extension (string-append opencog-ext-path-nlp-types "libnlp-types") "nlp_types_init")

; Load various parts....
(include-from-path "opencog/nlp/types/nlp_types.scm")
(include-from-path "opencog/nlp/nlp-utils.scm")

; Backwards compat
(define-public (LgConnectorNode . x)
   (apply cog-new-node (cons LgConnNodeType x)))

(define-public (LinkGrammarRelationshipNode . x)
	(apply cog-new-node (cons LgLinkNodeType x)))

; Weird ... MUST say `(export)` or no define-publics are visible!
; XXX What? nothing else anywhere needs this! FIXME, somethings broke.
(export)
