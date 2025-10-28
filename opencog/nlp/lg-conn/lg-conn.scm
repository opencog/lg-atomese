;
; lg-conn.scm
;
; Link Grammar connector expansion API
;
(define-module (opencog nlp lg-conn))

(use-modules (opencog) (opencog lg-config) (opencog nlp) (opencog exec))

(load-extension (string-append opencog-ext-path-lg-conn "liblg-conn") "opencog_nlp_lgconn_init")

; ---------------------------------------------------------------------
