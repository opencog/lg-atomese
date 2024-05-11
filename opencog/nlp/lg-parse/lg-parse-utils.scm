;
; lg-parse-utils.scm
;
; Assorted utilities for working with the LgParseLink output.
; Operations include:
; -- getting the various parses of a sentence
; -- getting the words in a parse
; -- getting assorted word properties
;
; The function names that can be found here are:
; -- sentence-get-parses    Get parses of a sentence.
; -- parse-get-words        Get all words occurring in a parse.
; -- parse-get-words-in-order  Get all words occurring in a parse in order.
; -- parse-get-links        Get all LG links in a parse.
; -- word-inst-get-parse    Return the ParseNode associated with word-inst.
; -- word-inst-get-number   Return the NumberNode associated with word-inst.
; -- word-inst-get-word     Return the WordNode associated with word-inst.
; -- word-inst-get-links    Get all LG links involving word-inst.
;
; The basic issue here is that the so-called 'RelEx format' makes heavy
; use of an indexed naming system, where each word-instance is stored
; in a unique node, and then everything is keyed off of that. It's
; verbose and ugly and poses memory-management issues.
;
; A side-effect of this ugliness is that some icky blebs of code are
; needed in otder to present a reasonably friendly programmer interface.
; That's what this file does. An ideal wolution would avoid the need
; for these helper utilities.
;
; Copyright (c) 2008, 2009, 2013 Linas Vepstas <linasvepstas@gmail.com>
; Copyright (c) 2015 OpenCog Foundation
;

(use-modules (srfi srfi-1))
(use-modules (opencog))

; ---------------------------------------------------------------------
(define-public (sentence-get-parses sent-node)
"
  sentence-get-parses    Get parses of a sentence.

  sentence-get-parses sent-node

  Given a sentence, return a list of parses in that sentence
  Basically, chase a ParseLink to a ParseNode
  Throws an error if sent-node is not a SentenceNode
"
	(cog-chase-link-chk 'ParseLink 'ParseNode sent-node 'SentenceNode)
)

; ---------------------------------------------------------------------

(define-public (parse-get-links parse-node)
"
  parse-get-links    Get all LG links in a parse.

  Given a parse, return a list of all LG links in that parse, i.e.
  the EvaluationLinks of the form

     EvaluationLink
        LgLinkNode 'foo'
        ListLink
           WordInstanceNode 'dog@12345'
           WordInstanceNode 'toy@6789'

"
	; Get a list of word-instances in the parse.
	; Get a list of lists of links for each word-instance.
	; concatenate! will reduce the list of lists to a plain list.
	; Remove duplicates
	(delete-duplicates!
		(concatenate!
			(map word-inst-get-links
				(parse-get-words parse-node))))
)

; ---------------------------------------------------------------------
(define-public (parse-get-words parse-node)
"
  parse-get-words - Return a list of all word-instances in the parse.

  Given a parse, return all word instances in arbitrary order
  This version is faster than the ordered version.
"
	(cog-chase-link 'WordInstanceLink 'WordInstanceNode parse-node)
)

; ---------------------------------------------------------------------
(define-public (parse-get-words-in-order PARSE)
"
  parse-get-words-in-order - Given PARSE, return a list of all word
  instances in the parse, in sequential order.
"
	; Get the scheme-number of the word-sequence number
	(define (get-number word-inst)
		(cog-number (word-inst-get-number word-inst)))

	(define (less-than word-inst-1 word-inst-2)
		(< (get-number word-inst-1) (get-number word-inst-2)))

	(sort (parse-get-words PARSE) less-than)
)

; ---------------------------------------------------------------------
(define-public (word-inst-get-parse word-inst)
"
  word-inst-get-parse   Return the ParseNode associated with word-inst

  Return the ParseNode associated with 'word-inst'
"
	(car (cog-chase-link 'WordInstanceLink 'ParseNode word-inst))
)

; ---------------------------------------------------------------------
(define-public (word-inst-get-number word-inst)
"
  word-inst-get-number   Return the NumberNode associated with word-inst

  Return the NumberNode associated with 'word-inst'. This number is
  the ordinal of the word in the sentence.  There can only ever be one
  such ordinal per WordInstance, so this returns a single atom.
"
	(car (cog-chase-link 'WordSequenceLink 'NumberNode word-inst))
)

; ---------------------------------------------------------------------
(define-public (word-inst-get-word word-inst)
"
  word-inst-get-word  -- Return the WordNode associated with word-inst

  Return the WordNode associated with 'word-inst'. For example, given
  `(WordInstance 'olah@12345')`, return `(WordNode 'olah')`

  There can only ever be one WordNode per WordInstance, so this returns
  a single atom.  However ...

  However, due to a RelEx bug, this function might throw an exception.
  Specifically, if the word in a sentence is a parenthesis, then the
  ReferenceLink between the specific paren, and the general paren does
  not get created.  Viz, there is no `(ReferenceLink (WordInstanceNode
  '(@4bf5e341-c6b') (WordNode '('))`. Some paren-counter somewhere is
  broken and gets confused. Beats me where. It should be fixed. In the
  meanhile, a 'wrong-type-arg exception is thrown, when the `car` below
  dereferences the empty list. Callers of this function may want to
  catch this exception.
"
	(car (cog-chase-link 'ReferenceLink 'WordNode word-inst))
)

; ---------------------------------------------------------------------
(define-public (word-inst-get-links word-inst)
"
  word-inst-get-links       Get LG links involving word-inst

  Given a word instance, return a list of all LG links that the
  word-instance participates in.  For example, given
  `(WordInstanceNode 'dog@12345')`, return all EvaluationLinks
  of the form

     EvaluationLink
        LgLinkNode 'foo'
        ListLink
           WordInstanceNode 'dog@12345'
           WordInstanceNode 'toy@6789'

  with the WordInstance in either the first or the second place.
"
	(cog-get-pred word-inst 'LgLinkNode)
)

; =============================================================
