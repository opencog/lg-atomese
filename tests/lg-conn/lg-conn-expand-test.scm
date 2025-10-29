;
; lg-conn-expand-test.scm
;
; Unit test for LgConnExpand

(use-modules (srfi srfi-64))
(use-modules (opencog))
(use-modules (opencog exec))
(use-modules (opencog lg))

(use-modules (opencog test-runner))

(opencog-test-runner)

(define tname "lg-conn-expand-test")
(test-begin tname)

; Test expansion with leading subtype and direction: "hWV+"
(define hwv-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "hWV+"))))

(test-assert "hWV+ returns Connector"
	(equal? 'Connector (cog-type hwv-expand)))

(define hwv-parts (cog-outgoing-set hwv-expand))
(test-assert "hWV+ has 3 parts"
	(equal? 3 (length hwv-parts)))

(test-assert "hWV+ first part is LgSubType h"
	(and (equal? 'LgSubType (cog-type (car hwv-parts)))
	     (equal? "h" (cog-name (car hwv-parts)))))

(test-assert "hWV+ second part is LgConnType WV"
	(and (equal? 'LgConnType (cog-type (cadr hwv-parts)))
	     (equal? "WV" (cog-name (cadr hwv-parts)))))

(test-assert "hWV+ third part is LgConnDir +"
	(and (equal? 'LgConnDirNode (cog-type (caddr hwv-parts)))
	     (equal? "+" (cog-name (caddr hwv-parts)))))

; Test expansion from LgConnector: "NXi" with "-" and "@"
(define nxi-expand
	(cog-execute!
		(LgConnExpand
			(LgConnector
				(LgConnNode "NXi")
				(LgConnDirNode "-")
				(LgConnMultiNode "@")))))

(test-assert "NXi connector returns Connector"
	(equal? 'Connector (cog-type nxi-expand)))

(define nxi-parts (cog-outgoing-set nxi-expand))
(test-assert "NXi has 4 parts"
	(equal? 4 (length nxi-parts)))

(test-assert "NXi first part is LgConnType NX"
	(and (equal? 'LgConnType (cog-type (car nxi-parts)))
	     (equal? "NX" (cog-name (car nxi-parts)))))

(test-assert "NXi second part is LgSubType i"
	(and (equal? 'LgSubType (cog-type (cadr nxi-parts)))
	     (equal? "i" (cog-name (cadr nxi-parts)))))

(test-assert "NXi third part is LgConnDir -"
	(and (equal? 'LgConnDirNode (cog-type (caddr nxi-parts)))
	     (equal? "-" (cog-name (caddr nxi-parts)))))

(test-assert "NXi fourth part is LgConnMulti @"
	(and (equal? 'LgConnMultiNode (cog-type (cadddr nxi-parts)))
	     (equal? "@" (cog-name (cadddr nxi-parts)))))

; Test basic expansion with wildcards: "Ds**c"
(define ds-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "Ds**c"))))

(test-assert "Ds**c returns Connector"
	(equal? 'Connector (cog-type ds-expand)))

(define ds-parts (cog-outgoing-set ds-expand))
(test-assert "Ds**c has 5 parts"
	(equal? 5 (length ds-parts)))

(test-assert "Ds**c first part is LgConnType D"
	(and (equal? 'LgConnType (cog-type (car ds-parts)))
	     (equal? "D" (cog-name (car ds-parts)))))

(test-assert "Ds**c second part is LgSubType s"
	(and (equal? 'LgSubType (cog-type (cadr ds-parts)))
	     (equal? "s" (cog-name (cadr ds-parts)))))

(test-assert "Ds**c third part is LgSubType *"
	(and (equal? 'LgSubType (cog-type (caddr ds-parts)))
	     (equal? "*" (cog-name (caddr ds-parts)))))

(test-assert "Ds**c fifth part is LgSubType c"
	(and (equal? 'LgSubType (cog-type (car (cddddr ds-parts))))
	     (equal? "c" (cog-name (car (cddddr ds-parts))))))

; Test expansion with no subscripts
(define simple-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "S"))))

(test-assert "S returns Connector"
	(equal? 'Connector (cog-type simple-expand)))

(test-assert "S has one element (main type)"
	(equal? 1 (length (cog-outgoing-set simple-expand))))

(test-assert "S main type is S"
	(and (equal? 'LgConnType (cog-type (gar simple-expand)))
	     (equal? "S" (cog-name (gar simple-expand)))))

; Test expansion with leading @ multi-connector: "@MX"
(define mx-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "@MX"))))

(test-assert "@MX returns Connector"
	(equal? 'Connector (cog-type mx-expand)))

(define mx-parts (cog-outgoing-set mx-expand))
(test-assert "@MX has 2 parts"
	(equal? 2 (length mx-parts)))

(test-assert "@MX first part is LgConnType MX"
	(and (equal? 'LgConnType (cog-type (car mx-parts)))
	     (equal? "MX" (cog-name (car mx-parts)))))

(test-assert "@MX second part is LgConnMulti @"
	(and (equal? 'LgConnMultiNode (cog-type (cadr mx-parts)))
	     (equal? "@" (cog-name (cadr mx-parts)))))

(test-end tname)

(opencog-test-end)
