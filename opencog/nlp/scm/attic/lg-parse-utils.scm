;
; lg-parse-utils.scm
; OBSOLETE. Here for reference purposes only.
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
;
(define-public (cog-map-apply-link link-type endpoint-type proc anchor)
"
  cog-map-apply-link link-type endpoint-type proc anchor

  Similar to cog-map-chase-link, except that the proc is not called
  on the endpoint, but rather on the link leading to the endpoint.
"
	(define (get-link l)
		(define (apply-link e) (proc l))
		(for-each apply-link (cog-outgoing-by-type l endpoint-type)))

	(for-each get-link (cog-incoming-by-type anchor link-type))
)

; ---------------------------------------------------------------------
(define-public (cog-get-link link-type endpoint-type anchor)
"
  cog-get-link link-type endpoint-type anchor

  Return a list of links, of type 'link-type', which contain some
  atom of type 'endpoint-type', and also specifically contain the
  atom 'anchor'.

  Thus, for example, suppose the atom-space contains a link of the
  form
        (ReferenceLink
            (ConceptNode \"asdf\")
            (WordNode \"pqrs\")
        )
  Then, the call
     (cog-get-link 'ReferenceLink 'ConceptNode (WordNode \"pqrs\"))
  will return a list containing that link. Note that \"endpoint-type\"
  need not occur in the first position in the link; it can appear
  anywhere.

"
	(let ((lst '()))
		(define (mklist inst)
			(set! lst (cons inst lst))
			#f)
		(cog-map-apply-link link-type endpoint-type mklist anchor)
		lst)
)

; ---------------------------------------------------------------------
(define-public (cog-get-pred inst pred-type)
"
  cog-get-pred -- Find all EvaluationLinks of given form.

  Return a list of predicates, of the given type, that an instance
  participates in.  'inst' must be an atom, and 'pred-type' must be
  an atom type.  That is, given a \"predicate\" of the form:

     EvaluationLink
        SomeAtom
        ListLink
            AnotherAtom \"abc\"
            GivenAtom \"def\"

  then, given the instance 'inst' (in this example, GivenAtom \"def\")
  and predicate type 'pred-type' 'SomeAtom, then this routine returns
  a list of all of the EvalutaionLink's in which 'inst' appears.
"
	(concatenate!
		(append!
			(map
				(lambda (lnk) (cog-get-link 'EvaluationLink pred-type lnk))
				(cog-incoming-by-type inst 'ListLink))))
)

; ---------------------------------------------------------------------
(define-public (cog-map-chase-link link-type endpoint-type proc anchor)
"
  cog-map-chase-link -- Invoke proc on atom connected through type.

  Similar to cog-chase-link, but invokes 'proc' on the wanted atom.
  Starting at the atom 'anchor', chase its incoming links of
  'link-type', and call procedure 'proc' on all of the atoms of
  type 'endpoint-type' in those links. For example, if 'anchor' is the
  node 'GivenNode \"a\"', and the atomspace contains

     SomeLink
         GivenNode \"a\"
         WantedNode  \"p\"

     SomeLink
         GivenNode \"a\"
         WantedNode  \"q\"

  then 'proc' will be called twice, with each of the WantedNodes's
  as the argument. These wanted nodes were found by following the
  link type 'SomeLink, starting at the anchor GivenNode \"a\".

  It is presumed that 'anchor' points to some atom (typically a node),
  and that it has many links in its incoming set. So, loop over all of
  the links of 'link-type' in this set. They presumably link to all
  sorts of things. Find all of the things that are of 'endpoint-type'.
  Apply proc to each of these.
"
	(define (get-endpoint w)
		(map proc (cog-outgoing-by-type w endpoint-type)))

	; We assume that anchor is a single atom, or empty list...
	(if (null? anchor)
		'()
		(map get-endpoint (cog-incoming-by-type anchor link-type)))
)

; ---------------------------------------------------------------------
(define-public (cog-chase-link link-type endpoint-type anchor)
"
  cog-chase-link -- Return other atom of a link connecting two atoms.

  cog-chase-link link-type endpoint-type anchor

  Starting at the atom 'anchor', chase its incoming links of
  'link-type', and return a list of all of the atoms of type
  'endpoint-type' in those links. For example, if 'anchor' is the
  node 'GivenNode \"a\"', and the atomspace contains

     SomeLink
         GivenNode \"a\"
         WantedNode  \"p\"

     SomeLink
         GivenNode \"a\"
         WantedNode  \"q\"

  then this method will return the two WantedNodes's, given the
  GivenNode as anchor, and the link-type 'SomeLink.

  viz: (cog-chase-link 'SomeLink 'WantedNode (GivenNode \"a\")) will
  return ((WantedNode \"p\") (WantedNode \"q\"))

  It is presumed that 'anchor' points to some atom (typically a node),
  and that it has many links in its incoming set. So, loop over all of
  the links of 'link-type' in this set. They presumably link to all
  sorts of things. Find all of the things that are of 'endpoint-type'.
  Return a list of all of these.
"
	(let ((lst '()))
		(define (mklist inst)
			(set! lst (cons inst lst))
			#f)
		(cog-map-chase-link link-type endpoint-type mklist anchor)
		lst)
)

; ---------------------------------------------------------------------
(define-public (sentence-get-parses sent-node)
"
  sentence-get-parses	 Get parses of a sentence.

  sentence-get-parses sent-node

  Given a sentence, return a list of parses in that sentence
  Basically, chase a ParseLink to a ParseNode
"
	(cog-chase-link 'ParseLink 'ParseNode sent-node)
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
