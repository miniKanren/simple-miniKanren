(load "test-cwa.scm")

;;; Testing Negation as Failure (NAF) in stable-Kanren
; p :- not a.
(define (a) fail)
(define (p) (noto (a)))

(test-check "testnaf.tex-1"   
(run* (q) (p) )

(list `_.0))

; a.
; p :- not a.
(define (a) succeed)
(define (p) (noto (a)))

(test-check "testnaf.tex-2"   
(run* (q) (p) )

`())

; a(1).
; p(X) :- not a(X).
;;; clingo will complain not a(X) is unsafe.
(define (a x)
  (conde 
    [(== x 1)]))
(define (p x) (noto (a x)))

;;; an ideal way will produce "_.0 ((x \= 1))".
(test-check "testnaf.tex-3"   
(run* (q) (p q) )

`())

(test-check "testnaf.tex-4"   
(run* (q) (noto (p q)) )

`(1))

(test-check "testnaf.tex-5"   
(run* (q) (p 1) )

`())

(test-check "testnaf.tex-6"   
(run* (q) (p 2) )

(list `_.0))

;;; Add new language construct 'defineo', so we can implicitly perform the rule
;;; translation.
(defineo (s) fail)
(defineo (r) fail)
(defineo (q)
  (conde
    [(noto (r))]
    [(s)]))
(defineo (p) (noto (q)))

(test-check "testnaf.tex-7"   
(run* (x) (p) )

`())

(test-check "testnaf.tex-8"   
(run* (x) (q) )

(list `_.0))
