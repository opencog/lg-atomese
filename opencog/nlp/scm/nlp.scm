(use-modules (opencog))

(define-module (opencog nlp)
  #:use-module (opencog)
  #:use-module (opencog lg-config)
)

; Load the C library; this calls the nameserver to load the types.
(load-extension (string-append opencog-ext-path-nlp-types "libnlp-types") "nlp_types_init")

; Load various parts....
(load "nlp/types/nlp_types.scm")
(load "nlp/nlp-utils.scm")

; Backwards compat
(define-public (LgConnnnectorNode . x)
   (apply cog-new-node (cons LgConnNodeType x)))


; Weird ... MUST say `(export)` or no define-publics are visible!
; XXX What? nothing else anywhere needs this! FIXME, somethings broke.
(export)
