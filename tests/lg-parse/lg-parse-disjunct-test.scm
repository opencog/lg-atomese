;
; lg-parse-disjunct-test.scm
;
; Super-simple unit test, based on example

(use-modules (srfi srfi-64))
(use-modules (opencog))
(use-modules (opencog exec))
(use-modules (opencog lg))

(use-modules (opencog test-runner))

(opencog-test-runner)

(define tname "lg-parse-disjunct-test")
(test-begin tname)

(cog-execute!
	(LgParseDisjuncts
		(PhraseNode "this is a test.")
		(LgDictNode "en")
		(NumberNode 55)))

(define test-dj
	(cog-link 'LgDisjunct
		(WordNode "test")
		(ConnectorSeq
			(LgConnector
				(LgConnNode "Ds**c")
				(LgConnDirNode "-"))
			(LgConnector
				(LgConnNode "Os")
				(LgConnDirNode "-")))))

(test-assert "Disjunct exists"
	(not (eq? #f test-dj)))

(test-end tname)

(opencog-test-end)
