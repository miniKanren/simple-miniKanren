;;; Representing sets as unordered lists.
; O(n) complexity.
(define (element-of-set? x set)
  (cond ((null? set) #f)
        ((equal? x (get-key (car set))) (car set))
        (else (element-of-set? x (cdr set)))))

; O(1) complexity.
(define (adjoin-set x set) (cons x set))

(define (make-record key value)
  (cons key value))

(define (get-key record)
  (car record))

(define (get-value record)
  (cdr record))

(define (set-value record value)
  (set-cdr! record value))
