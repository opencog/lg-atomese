;
; lg-conn-expand-test.scm
;
; Unit test for LgConnExpand

(use-modules (srfi srfi-64))
(use-modules (opencog))
(use-modules (opencog exec))
(use-modules (opencog nlp))
(use-modules (opencog nlp lg-conn))
(use-modules (opencog test-runner))

(opencog-test-runner)

(define tname "lg-conn-expand-test")
(test-begin tname)

; Test basic expansion with subscripts
(define expand-result
	(cog-execute!
		(LgConnExpand (LgConnNode "Ds**c"))))

(test-assert "LgConnExpand returns Connector"
	(equal? 'Connector (cog-type expand-result)))

; Verify the main connector type is correct
(define conn-type (gar expand-result))
(test-assert "Main type is LgConnType"
	(equal? 'LgConnType (cog-type conn-type)))

(test-assert "Main type value is D"
	(equal? "D" (cog-name conn-type)))

; Verify we have the right number of subtypes (4: s, *, *, c)
(define subtypes (cdr (cog-outgoing-set expand-result)))
(test-assert "Has 4 subtypes"
	(equal? 4 (length subtypes)))

; Verify first subtype
(test-assert "First subtype is s"
	(and (equal? 'LgSubType (cog-type (car subtypes)))
	     (equal? "s" (cog-name (car subtypes)))))

; Verify second subtype
(test-assert "Second subtype is *"
	(and (equal? 'LgSubType (cog-type (cadr subtypes)))
	     (equal? "*" (cog-name (cadr subtypes)))))

; Verify fourth subtype
(test-assert "Fourth subtype is c"
	(and (equal? 'LgSubType (cog-type (cadddr subtypes)))
	     (equal? "c" (cog-name (cadddr subtypes)))))

; Test expansion with no subscripts
(define simple-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "S"))))

(test-assert "Simple expansion returns Connector"
	(equal? 'Connector (cog-type simple-expand)))

(test-assert "Simple expansion has one element (main type)"
	(equal? 1 (length (cog-outgoing-set simple-expand))))

(test-assert "Simple expansion main type is S"
	(equal? "S" (cog-name (gar simple-expand))))

; Test expansion with multi-letter main type
(define multi-expand
	(cog-execute!
		(LgConnExpand (LgConnNode "MVp"))))

(test-assert "Multi-letter main type is MV"
	(equal? "MV" (cog-name (gar multi-expand))))

(define multi-subtypes (cdr (cog-outgoing-set multi-expand)))
(test-assert "Multi-letter has 1 subtype"
	(equal? 1 (length multi-subtypes)))

(test-assert "Multi-letter subtype is p"
	(equal? "p" (cog-name (car multi-subtypes))))

(test-end tname)

(opencog-test-end)
