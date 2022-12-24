;;; This file was generated by writeminikanren.pl
;;; Generated at 2007-10-25 15:24:42
(load "utils.scm")

(define-syntax lambdag@
  (syntax-rules ()
    ((_ (n cfs s) e) (lambda (n cfs s) e))))

(define-syntax lambdaf@
  (syntax-rules ()
    ((_ () e) (lambda () e))))

(define-syntax run*
  (syntax-rules ()
    ((_ (x) g ...) (run #f (x) g ...))))

(define rhs (lambda (pr) (cdr pr)))

(define lhs (lambda (pr) (car pr)))

(define var (lambda (x) (vector x)))

(define var? (lambda (x) (vector? x)))

(define empty-s '())

(define negation-counter 0)

(define call-frame-stack '())

(define walk
  (lambda (u S)
    (cond
      ((and (var? u) (assq u S)) =>
       (lambda (pr) (walk (rhs pr) S)))
      (else u))))

(define ext-s
  (lambda (x v s)
    (cons `(,x . ,v) s)))

(define unify
  (lambda (u v s)
    (let ((u (walk u s))
          (v (walk v s)))
      (cond
        ((eq? u v) s)
        ((var? u) (ext-s-check u v s))
        ((var? v) (ext-s-check v u s))
        ((and (pair? u) (pair? v))
         (let ((s (unify 
                    (car u) (car v) s)))
           (and s (unify 
                    (cdr u) (cdr v) s))))
        ((equal? u v) s)
        (else #f)))))

(define ext-s-check
  (lambda (x v s)
    (cond
      ((occurs-check x v s) #f)
      (else (ext-s x v s)))))

(define occurs-check
  (lambda (x v s)
    (let ((v (walk v s)))
      (cond
        ((var? v) (eq? v x))
        ((pair? v) 
         (or 
           (occurs-check x (car v) s)
           (occurs-check x (cdr v) s)))
        (else #f)))))

(define walk*
  (lambda (w s)
    (let ((v (walk w s)))
      (cond
        ((var? v) v)
        ((pair? v)
         (cons
           (walk* (car v) s)
           (walk* (cdr v) s)))
        (else v)))))

(define reify-s
  (lambda (v s)
    (let ((v (walk v s)))
      (cond
        ((var? v)
         (ext-s v (reify-name (length s)) s))
        ((pair? v) (reify-s (cdr v)
                     (reify-s (car v) s)))
        (else s)))))

(define reify-name
  (lambda (n)
    (string->symbol
      (string-append "_" "." (number->string n)))))

(define reify
  (lambda (v s)
    (let ((v (walk* v s)))
      (walk* v (reify-s v empty-s)))))

(define mzero (lambda () #f))

(define-syntax inc 
  (syntax-rules () ((_ e) (lambdaf@ () e))))

(define unit (lambda (c) c))

(define choice (lambda (c f) (cons c f)))
 
(define-syntax case-inf
  (syntax-rules ()
    ((_ e (() e0) ((f^) e1) ((a^) e2) ((a f) e3))
     (let ((a-inf e))
       (cond
         ((not a-inf) e0)
         ((procedure? a-inf)  (let ((f^ a-inf)) e1))
         ((not (and (pair? a-inf)
                    (procedure? (cdr a-inf))))
          (let ((a^ a-inf)) e2))
         (else (let ((a (car a-inf)) (f (cdr a-inf))) 
                 e3)))))))

(define-syntax run
  (syntax-rules ()
    ((_ n (x) g0 g ...)
     (take n
       (lambdaf@ ()
         ((fresh (x) g0 g ... 
            (lambdag@ (negation-counter call-frame-stack s)
              (cons (reify x s) '())))
          negation-counter call-frame-stack empty-s))))))
 
(define take
  (lambda (n f)
    (if (and n (zero? n)) 
      '()
      (case-inf (f)
        (() '())
        ((f) (take n f))
        ((a) a)
        ((a f)
         (cons (car a)
           (take (and n (- n 1)) f)))))))

(define ==
  (lambda (u v)
    (lambdag@ (n cfs s)
      (if (even? n)
        (cond
          [(unify u v s) => 
            (lambda (s+) 
              (unit s+))]
          [else (mzero)])
        (cond
          [(unify u v s) => 
            (lambda (s+) 
              (mzero))]
          [else (unit s)])))))

(define-syntax fresh
  (syntax-rules ()
    ((_ (x ...) g0 g ...)
     (lambdag@ (n cfs s)
       (inc
         (let ((x (var 'x)) ...)
           (bind* n cfs (g0 n cfs s) g ...)))))))
 
(define-syntax bind*
  (syntax-rules ()
    ((_ n cfs e) e)
    ((_ n cfs e g0 g ...) (bind* n cfs (bind n cfs e g0) g ...))))
 
(define bind
  (lambda (n cfs a-inf g)
    (case-inf a-inf
      (() (mzero))
      ((f) (inc (bind n cfs (f) g)))
      ((a) (g n cfs a))
      ((a f) (mplus (g n cfs a) (lambdaf@ () (bind n cfs (f) g)))))))

(define-syntax conde
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs s) 
       (inc 
         (mplus* 
           (bind* n cfs (g0 n cfs s) g ...)
           (bind* n cfs (g1 n cfs s) g^ ...) ...))))))

;;; Turns conjunction of goals (g0, g, ...) into disjunction of goals (g0; g; ...).
(define-syntax conde-t
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (fresh ()
       (conde [g0] [g] ...)
       (conde [g1] [g^] ...) ...))))

;;; Transform the original rule to the complement form.
(define-syntax complement
  (syntax-rules (conde)
    ((_ (conde (g0 g ...) (g1 g^ ...) ...)) 
     (conde-t (g0 g ...) (g1 g^ ...) ...))
    ((_ g0 g ...)
     (conde-t (g0 g ...)))))
 
(define-syntax mplus*
  (syntax-rules ()
    ((_ e) e)
    ((_ e0 e ...) (mplus e0 
                    (lambdaf@ () (mplus* e ...))))))
 
(define mplus
  (lambda (a-inf f)
    (case-inf a-inf
      (() (f))
      ((f^) (inc (mplus (f) f^)))
      ((a) (choice a f))
      ((a f^) (choice a (lambdaf@ () (mplus (f) f^)))))))

(define-syntax conda
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs s)
       (inc
         (ifa n cfs ((g0 n cfs s) g ...)
                   ((g1 n cfs s) g^ ...) ...))))))
 
(define-syntax ifa
  (syntax-rules ()
    ((_ n cfs) (mzero))
    ((_ n cfs (e g ...) b ...)
     (let loop ((a-inf e))
       (case-inf a-inf
         (() (ifa n cfs b ...))
         ((f) (inc (loop (f))))
         ((a) (bind* n cfs a-inf g ...))
         ((a f) (bind* n cfs a-inf g ...)))))))

(define-syntax condu
  (syntax-rules ()
    ((_ (g0 g ...) (g1 g^ ...) ...)
     (lambdag@ (n cfs s)
       (inc
         (ifu n cfs ((g0 n cfs s) g ...)
                   ((g1 n cfs s) g^ ...) ...))))))
 
(define-syntax ifu
  (syntax-rules ()
    ((_ n cfs) (mzero))
    ((_ n cfs (e g ...) b ...)
     (let loop ((a-inf e))
       (case-inf a-inf
         (() (ifu n cfs b ...))
         ((f) (inc (loop (f))))
         ((a) (bind* n cfs a-inf g ...))
         ((a f) (bind* n cfs (unit a) g ...)))))))

(define-syntax project
  (syntax-rules ()
    ((_ (x ...) g g* ...)
     (lambdag@ (n cfs s)
       (let ((x (walk* x s)) ...)
         ((fresh () g g* ...) n cfs s))))))

(define succeed (== #f #f))

(define fail (== #f #t))

(define onceo
  (lambda (g)
    (condu
      (g succeed)
      ((== #f #f) fail))))

(define-syntax noto
  (syntax-rules ()
    ((noto (name args ...))
      (lambdag@ (n cfs s)
        ((name args ...) (+ 1 n) cfs s)))))

(define-syntax defineo
  (syntax-rules ()
    ((_ (name args ...) exp ...)
      ;;; Define a goal function with the original rules "exp ...", and the 
      ;;; complement rules "complement exp ..."
      (define name (lambda (args ...)
        (lambdag@ (n cfs s)
          ;;; During the execution, the goal function picks the corresponding
          ;;; rule set based on the value of the negation counter.
          ;;;   n >= 0 and even, use original rules
          ;;;   n >= 0 and odd, use complement rules
          ((cond ((even? n) (fresh () exp ...))
                 ((odd? n) (complement exp ...))
                 (else fail))
            n cfs s)))))))
