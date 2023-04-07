(load "test-naf.scm")

;;; Testing Two Person Game in stable-Kanren
(reset-program)
(defineo (edge x y)
  (conde
    [(== x 'b) (== y 'c)]
    [(== x 'a) (== y 'b)]
    [(== x 'b) (== y 'a)]
    [(== x 'c) (== y 'd)]))

(defineo (win x)
  (conde
    [(fresh (y)
      (edge x y)
      (noto (win y)))]))

;;; Loop over negation.
(test-check "testtpg.tex-1a"
(run 1 (q) (win 'a) )

(list `_.0))

(test-check "testtpg.tex-1b"
(run 1 (q) (win 'b) )

(list `_.0))

(test-check "testtpg.tex-1c"
(run 1 (q) (win 'c) )

(list `_.0))

(test-check "testtpg.tex-1d"
(run 1 (q) (win 'd) )

`())

;;; Partial result.
(test-check "testtpg.tex-2ab"
(run 1 (q) (win 'a) (win 'b))

`())

(test-check "testtpg.tex-2ac"
(run 1 (q) (win 'a) (win 'c))

(list `_.0))

(test-check "testtpg.tex-2bc"
(run 1 (q) (win 'c) (win 'b))

(list `_.0))


(test-check "testtpg.tex-3"
(sort compare-element (remove-duplicates 
  (run* (q) (win q))))

`(a b c))