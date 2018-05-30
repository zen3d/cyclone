(import
  (scheme base)
  (scheme cyclone ast)
  (scheme cyclone util)
  (scheme cyclone pretty-print)
  (scheme write)
  ;(srfi 2)
)

  (define (find-direct-recursive-calls exp)
    (define (scan exp def-sym)
      (write `(scan ,def-sym ,exp)) (newline)
      (cond
       ((ast:lambda? exp)
        #f)
       ((quote? exp) exp)
       ((const? exp) exp)
       ((ref? exp) 
        exp)
       ((define? exp) #f)
       ((set!? exp) #f)
       ((if? exp)       
        (scan (if->condition exp) def-sym)
        (scan (if->then exp) def-sym)
        (scan (if->else exp) def-sym))
       ((app? exp)
        (when (equal? (car exp) def-sym)
          (write `(possible direct recursive call ,exp)))
       )
       (else #f)))
    (for-each
      (lambda (exp)
        (cond
          ((and-let* (((define? exp))
                      (def-exps (define->exp exp))
                      (ast:lambda? (car def-exps))
                     )
           (scan (car (ast:lambda-body (car def-exps))) (define->var exp))))
          (else #f)))
        exp)
  )

;; TEST code:
(define sexp '(
 (define l18 #f)
 (define l12 #f)
 (define l6 #f)
 (define mas
   (lambda
     (k$247 x$4$135 y$3$134 z$2$133)
     (shorterp
       (lambda
         (r$248)
         (if r$248
           (mas (lambda
                  (r$249)
                  (mas (lambda
                         (r$250)
                         (mas (lambda
                                (r$251)
                                (mas k$247 r$249 r$250 r$251))
                              (cdr z$2$133)
                              x$4$135
                              y$3$134))
                       (cdr y$3$134)
                       z$2$133
                       x$4$135))
                (cdr x$4$135)
                y$3$134
                z$2$133)
           (k$247 z$2$133)))
       y$3$134
       x$4$135)))
 (define shorterp
   (lambda
     (k$240 x$6$131 y$5$130)
     (if (null? y$5$130)
       (k$240 #f)
       (if (null? x$6$131)
         (k$240 (null? x$6$131))
         (shorterp k$240 (cdr x$6$131) (cdr y$5$130))))))
))

;(pretty-print (ast:sexp->ast sexp))
(find-direct-recursive-calls
  (ast:sexp->ast sexp))
