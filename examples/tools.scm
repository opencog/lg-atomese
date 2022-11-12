;
; tools.scm
;
; Some handly utilities for exploring and debugging.
;
; These take LgConnector and LgDisjunct's and print them
; in a more conventional LG-style format.

; Print a single LgConnNode
(define (prt-node port lk) (format port "~A" (cog-name lk)))

; Print an LgConnector as link type and direction
(define (prt-ctcr port ctcr)
	(prt-node port (gar ctcr))
	(prt-node port (gdr ctcr)))

; Print a list of connectors
(define (prt-ctcr-list port ctl)
	(prt-ctcr port (car ctl))
	(when (< 1 (length ctl))
		(format port " & ")
		(prt-ctcr-list port (cdr ctl))))

; Print an LgAnd connector sequence
(define (prt-cnsq port cnsq)
	(prt-ctcr-list port (cog-outgoing-set cnsq)))

; Print an LgDisjunct and its count
(define (prt-sect port sect)
	(prt-node port (gar sect))
	(format port " : ")
	(prt-cnsq port (gdr sect))
	(format port " [~D];\n" (cog-count sect)))

; Print a list of disjuncts
;
; Example usage:
; (define pda (LgParseDisjuncts ...))
; (prt-sect-list #t (cog-value->list (cog-execute! pda)))
;
(define (prt-sect-list port scl)
	(prt-sect port (car scl))
	(if (not (nil? (cdr scl)))
		(prt-sect-list port (cdr scl))))


