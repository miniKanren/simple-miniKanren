(load "test-naf.scm")

;;; Testing Two Person Game in stable-Kanren
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

(test-check "testtpg.tex-a"   
(run 1 (q) (win 'a) )

(list `_.0))

(test-check "testtpg.tex-b"   
(run 1 (q) (win 'b) )

(list `_.0))

(test-check "testtpg.tex-c"   
(run 1 (q) (win 'c) )

(list `_.0))

(test-check "testtpg.tex-d"   
(run 1 (q) (win 'd) )

`())
