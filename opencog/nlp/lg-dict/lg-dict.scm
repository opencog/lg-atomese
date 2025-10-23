;
; lg-dict.scm
;
; Link Grammar dictionary API
;
(define-module (opencog nlp lg-dict))

(use-modules (srfi srfi-1) (opencog) (opencog lg-config) (opencog nlp) (opencog exec))

(load-extension (string-append opencog-ext-path-lg-dict "liblg-dict") "opencog_nlp_lgdict_init")

; ---------------------------------------------------------------------

(export lg-conn-type-match?)
(set-procedure-property! lg-conn-type-match? 'documentation
"
  lg-conn-type-match? CON-A CON-B
     Return #t if connector CON-A matches CON-B, else return #f.
     Both CON-A and CON-B must be of type LgConnector.

     This does NOT check connector direction agreement; it only
     checks the connector strings, using the standard Link Grammar
     connector matching rules.
")

(export lg-conn-linkable?)
(set-procedure-property! lg-conn-linkable? 'documentation
"
  lg-conn-linkable? CON-A CON-B
     Return #t if connector CON-A can link to CON-B, else return #f.
     Both CON-A and CON-B must be of type LgConnector.

     This checks the connector strings for linkability, using the
     standard Link Grammar connector matching rules.
")

; ---------------------------------------------------------------------
