;;;; A simple example of using a condition variable to simulate thread-join
(import (scheme base)
        (scheme read)
        (scheme write)
        (srfi 18))

(define cv (make-condition-variable))
(define m (make-mutex))

;; Thread - Do something, then let main thread know when we are done
(thread-start!
  (make-thread
    (lambda ()
      (display "started thread")
      (newline)
      (thread-sleep! 3)
      (display "thread done")
      (newline)
      (condition-variable-broadcast! cv))))

;; Main thread - wait for thread to broadcast it is done
(mutex-lock! m)
(mutex-unlock! m cv) ;; Wait on cv
(display "main thread done")
(newline)
(thread-sleep! 0.5)

;(display "thread join")
;(newline)
;(let ((t (make-thread
;            (lambda ()
;              (display "started second thread")
;              (newline)
;              (thread-sleep! 3)
;              (display "thread done")
;              (newline)
;              1))))
;  (thread-start! t)
;  (thread-sleep! 0)
;  (display (thread-join! t))
;  (display "main thread done again")
;  (newline))
