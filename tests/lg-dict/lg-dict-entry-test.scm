;
; lg-dict-entry-test.scm
;
; Unit test for LgDictEntry and LgHaveDictEntry

(use-modules (srfi srfi-64))
(use-modules (opencog))
(use-modules (opencog exec))
(use-modules (opencog lg))

(use-modules (opencog test-runner))

(opencog-test-runner)

(define tname "lg-dict-entry-test")
(test-begin tname)

; Test LgDictEntry - should return a LinkValue containing disjuncts
(define dict-result
	(cog-execute!
		(LgDictEntry (Word "test") (LgDictNode "en"))))

(test-assert "LgDictEntry returns LinkValue"
	(equal? 'LinkValue (cog-type dict-result)))

; Test LgHaveDictEntry with a word that exists
(define have-test
	(cog-execute!
		(LgHaveDictEntry (Word "test") (LgDictNode "en"))))

(test-assert "LgHaveDictEntry finds existing word"
	(equal? (BoolValue #t) have-test))

; Test LgHaveDictEntry with a word that doesn't exist
(define no-have-test
	(cog-execute!
		(LgHaveDictEntry (Word "asdfqwerzxcv") (LgDictNode "en"))))

(test-assert "LgHaveDictEntry rejects non-existent word"
	(equal? (BoolValue #f) no-have-test))

(test-end tname)

(opencog-test-end)
