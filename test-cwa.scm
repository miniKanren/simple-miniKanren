(load "mktests.scm")

;;; Testing Closed World Assumption (CWA) in stable-Kanren
; p :- a.
(define (p) (a))
(define (a) fail)

(test-check "testcwa.tex-1"   
(run* (q) (p) )

`())

; p(X) :- a(X).
(define (p x) (a x))
(define (a x) fail)

(test-check "testcwa.tex-2"   
(run* (q) (p q) )

`())

; p(X) :- a(X).
; a(X) :- X=1..3.
(define (p x) (a x))
(define (a x)
  (conde
    [(== x 1)]
    [(== x 2)]
		[(== x 3)]))

(test-check "testcwa.tex-3"   
(run* (q) (p q) )

`(1 2 3))

(test-check "testcwa.tex-4"   
(run* (q) (p 4) )

`())
