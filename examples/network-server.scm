;
; network-server.scm
;
; The server side of a client-server implementation for Link Grammar
; parsing. Start the server by running this file, e.g. by saying
; `guile -l network-server.scm`.
;
; The code here is more-or-less trivial. It just starts the cogserver.
; As a general rule, if you want to parse from some custom dataset, you
; will need to load that dataset into the AtomSpace.  The demo here just
; uses the file-backed English `en` dictionary, and so the server setup
; is trivial.
;
; You can monitor what the cogserver is doing by running the following:
; ```
; $ rlwrap telnet localhost 17003
; opencog> help
; opencog> stats
; opencog> top
; ```
; Use ctrl-C to interrupt the running `top` command.
;
(use-modules (opencog) (opencog exec))
(use-modules (opencog cogserver))
(use-modules (opencog nlp) (opencog nlp lg-parse))

; Start the cogserver on localhost, at port 17003
(start-cogserver #:port 17003)
