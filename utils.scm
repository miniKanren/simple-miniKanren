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

;;; Get first n elements from a list.
; O(n) complexity.
(define (get-first-n-elements l n)
  (if (or (= n 0) (null? l))
    `()
    (cons (car l) (get-first-n-elements (cdr l) (- n 1)))))

;;; Find bounded variables from a substitution.
; O(n) complexity.
(define (find-bound-vars argv S)
  (if (null? argv)
      '()
      (let ((key (walk (car argv) S)))
        (if (not (var? key))
            (cons (car argv) (find-bound-vars (cdr argv) S))
            (find-bound-vars (cdr argv) S)))))

;;; Extend a substitution with <variable, value> pairs.
; O(n) complexity, where n is the length of <variable, value> list.
(define (ext-s-for-all-vars vars values S)
  (if (null? vars)
      S
      (ext-s-for-all-vars 
          (cdr vars) 
          (cdr values) 
          (ext-s (car vars) (car values) S))
))

;;; Check if a variable is in a list of variables.
; O(n) complexity.
(define (contain? var var-to-remove)
  (cond ((null? var-to-remove) #f)
        ((eq? var (car var-to-remove)) #t)
        (else (contain? var (cdr var-to-remove)))))

;;; Remove a list of variables from a given removal list.
; O(n^2) complexity.
(define (remove-var-from-list var-list var-to-remove)
  (cond ((null? var-list) `())
        ((contain? (car var-list) var-to-remove) 
          (remove-var-from-list (cdr var-list) var-to-remove))
        (else 
          (cons (car var-list) 
                (remove-var-from-list (cdr var-list) var-to-remove)))))

;;; Remove duplicates in the list.
(define (remove-duplicates l)
  (cond ((null? l) `())
        ((member (car l) (cdr l))
          (remove-duplicates (cdr l)))
        (else
          (cons (car l) (remove-duplicates (cdr l))))))

;;; Comparison function for sorting.
(define (compare-element lhs rhs)
  (string<? (format "~a" lhs) (format "~a" rhs)))
