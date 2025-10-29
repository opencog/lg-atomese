(use-modules (opencog))

(define-module (opencog lg)
	#:use-module (opencog)
	#:use-module (opencog lg-config)
)

; Load the C library types
(load-extension (string-append opencog-ext-path-lg-types "liblg-types") "lg_types_init")
(include-from-path "opencog/lg/types/lg_types.scm")

; Load the three LG subsystem libraries - they register into this module
(load-extension (string-append opencog-ext-path-lg-conn "liblg-conn") "opencog_nlp_lgconn_init")
(load-extension (string-append opencog-ext-path-lg-dict "liblg-dict") "opencog_nlp_lgdict_init")
(load-extension (string-append opencog-ext-path-lg-parse "liblg-parse") "opencog_nlp_lgparse_init")

; Export functions from lg-dict
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
