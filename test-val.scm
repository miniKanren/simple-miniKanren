(load "test-tpg.scm")

(reset-program)
(defineo (edge x y)
  (conde
    [(== x 'b) (== y 'c)]
    [(== x 'a) (== y 'b)]
    [(== x 'b) (== y 'a)]
    [(== x 'c) (== y 'd)]))

;;; Testing ignore negation in stable-Kanren
(define-syntax test-ignore-negation
  (syntax-rules ()
    ((_ (name args ...) exp ...)
      (define (name args ...)
        (ignore-negation exp ...)))))

(test-ignore-negation (win x)
  (conde
    [(fresh (y)
      (edge x y)
      (noto (win y)))]))

(test-check "testval.tex-ignore-negation"
(sort compare-element (remove-duplicates 
  (run* (q) (win q))))

`(a b c))

(defineo (win x)
  (conde
    [(fresh (y)
      (edge x y)
      (noto (win y)))]))


(test-check "testval.tex-1a"
(sort compare-element (remove-duplicates 
  (take #f 
    (lambdaf@ ()
      ((fresh (tmp)
        (win tmp)
        (lambdag@ (n f c : S P)
          (cons (reify tmp S) '())))
        ground-program call-frame-stack empty-c)))))

`(a b c))


(reset-program)
; p(X) :- not q(X), a(X).
(defineo (p x)
  (noto (q x))
  (a x))

; q(X) :- not p(X), b(X).
(defineo (q x)
  (noto (p x))
  (b x))

; a(1).
; a(2).
(defineo (a x)
  (conde [(== x 1)]
         [(== x 2)]))

; b(2).
; b(3).
(defineo (b x)
  (conde [(== x 2)]
         [(== x 3)]))

(test-check "testval.tex-1b"
(sort compare-element (remove-duplicates 
  (take #f 
    (lambdaf@ ()
      ((fresh (tmp)
        (p tmp)
        (lambdag@ (n f c : S P)
          (cons (reify tmp S) '())))
        ground-program call-frame-stack empty-c)))))

`(1 2))

(test-check "testval.tex-1c"
(sort compare-element (remove-duplicates 
  (take #f 
    (lambdaf@ ()
      ((fresh (tmp)
        (q tmp)
        (lambdag@ (n f c : S P)
          (cons (reify tmp S) '())))
        ground-program call-frame-stack empty-c)))))

`(2 3))
