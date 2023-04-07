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

;;; Stratified negation, loop and negation does not mixed together.
(reset-program)
; a :- b.
; b :- a.
; c :- not a.
; c :- d.
; d :- c.
; e :- not d.
(defineo (a) (b))
(defineo (b) (a))
(defineo (c) 
  (conde 
    [(noto (a))]
    [(d)]))
(defineo (d) (c))
(defineo (e) (noto (d)))

(test-check "testnaf.tex-9a"   
(run* (q) (c) (d) )

(list `_.0))

(test-check "testnaf.tex-9b"   
(run* (q) (a) (b) (e) )

`())

;;; Stratified negation, example taken from 
;;; https://www3.cs.stonybrook.edu/~warren/xsbbook/node59.html
;;; For stratified negation, the loop can't has negation in it. We are using the
;;; loop part of the example to test stable-Kanren's ability to handle positive
;;; loop in the program.
(reset-program)
(defineo (reduce x y)
  (conde
    [(== x 'a) (== y 'b)]
    [(== x 'b) (== y 'c)]
    [(== x 'c) (== y 'd)]
    [(== x 'd) (== y 'e)]
    [(== x 'e) (== y 'c)]
    [(== x 'a) (== y 'f)]
    [(== x 'f) (== y 'h)]
    [(== x 'f) (== y 'g)]
    [(== x 'g) (== y 'f)]
    [(== x 'g) (== y 'k)]
    [(== x 'h) (== y 'i)]
    [(== x 'i) (== y 'h)]))

;reachable(X,Y) :- reduce(X,Y).
;reachable(X,Y) :- reachable(X,Z), reduce(Z,Y).
(defineo (reachable x y)
  (conde
    [(reduce x y)]
    [(fresh (z) (reduce x z) (reachable z y))]))

(test-check "testnaf.tex-10a"   
(sort compare-element (remove-duplicates
  (run* (q) (fresh (x y) (reachable x y) (== q `(,x ,y))) )))

`((a b) (a c) (a d) (a e) (a f) (a g) (a h) (a i) (a k) (b c)
  (b d) (b e) (c c) (c d) (c e) (d c) (d d) (d e) (e c) (e d)
  (e e) (f f) (f g) (f h) (f i) (f k) (g f) (g g) (g h) (g i)
  (g k) (h h) (h i) (i h) (i i)))

;reducible(X) :- reachable(X,Y), not reachable(Y,X).
(defineo (reducible x)
  (conde
   [(fresh (y) (reachable x y) (noto (reachable y x)))]))

(test-check "testnaf.tex-10b"   
(run 1 (q) (reducible 'a) (reducible 'b) (reducible 'g) (reducible 'f) 
           (noto (reducible 'c)) (noto (reducible 'd)) (noto (reducible 'e))
           (noto (reducible 'h)) (noto (reducible 'i)) (noto (reducible 'k)) )

(list `_.0))

; test run* to get all answers.
; [ToDo] Performance optimization.
(reset-program)
(test-check "testnaf.tex-10c"   
(sort compare-element (remove-duplicates 
  (run* (q) (reducible q) )))

`(a b f g))

;fullyReduce(X,Y) :- reachable(X,Y), not reducible(Y).
(defineo (fullyReduce x y)
  (conde
    [(reachable x y) (noto (reducible y))]))

; test final-SCC problem run* to get all final-SCC.
; [ToDo] Performance optimization.
(reset-program)
(test-check "testnaf.tex-10d"   
(sort compare-element (remove-duplicates 
  (run* (q) (fresh (x y) (fullyReduce x y) (== q `(,x ,y))) )))

`((a c) (a d) (a e) (a h) (a i) (a k) (b c) (b d) (b e) (c c)
  (c d) (c e) (d c) (d d) (d e) (e c) (e d) (e e) (f h) (f i)
  (f k) (g h) (g i) (g k) (h h) (h i) (i h) (i i)))
