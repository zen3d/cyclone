;;;; A temporary test file, this code needs to be separated into a library and a set of unit tests

;TODO: a queue that can be shared among threads
;objects on the queue must be shared objects, possibly immutable (but more flexible if not)
;consider making the queue vector-based, and increase size by 2 if capacity is exceeded?
;
;supported operations:
;
;- queue?
;- (queue ...) constructor
;- queue-add! - add item to the queue
;- queue-remove! - remove item (when to block? would be nice if we can block until an item becomes available)
;            maybe block by default, but have an optional timeout
;- queue-get - ?? 
;- queue-clear!
;- queue->list
;- queue-size (current length)
;- queue-capacity (max size until resize occurs)
;- queue-empty?

(define-library (shared-queue)

(import (scheme base)
        (cyclone test)
        (cyclone concurrent)
        (srfi 18)
        (scheme write))

(export
  queue?
  make-queue
  queue
  queue-add!
  %queue-add! ;; DEBUG
  %queue-remove!
)

(begin

(define *default-table-size* 4) ;; TODO: 64)

;TODO: how will data structure work?
;probably want a circular queue, add at end and remove from start
;need to keep track of those positions, they may wrap around the end
;of the queue
;so we need - start, end
;capacity is length of the vector
;if start == end, vector is empty
;if start == end after an add, then vector is full, need to resize

  (define-record-type <queue>
    (%make-queue store start end lock)
    queue?
    (store q:store q:set-store!)
    (start q:start q:set-start!)
    (end q:end q:set-end!)
    (lock q:lock q:set-lock!))

(define (make-queue)
  (make-shared
    (%make-queue
      (make-vector *default-table-size* #f)
      0
      0
      (make-mutex))))

(define (queue . elems)
  (let ((q (make-queue)))
    (for-each
      (lambda (elem)
        (%queue-add! q elem))
      (reverse elems))))

(define (inc index capacity)
  (if (= index (- capacity 1))
      0
      (+ index 1)))

;; Inner add, assumes we already have the lock
(define (%queue-add! q obj)
  (vector-set! (q:store q) (q:end q) (make-shared obj))
  (q:set-end! q (inc (q:end q) (vector-length (q:store q))))
  (when (= (q:start q) (q:end q))
     (%queue-resize! q))
)

(define (queue-add! q obj)
  (mutex-lock! (q:lock q))
  (%queue-add! q obj)
  (mutex-unlock! (q:lock q))
)

(define (%queue-resize! q)
  (write "TODO: resize the queue")(newline)
;  ;; TODO: assumes we already have the lock
;  ;; TODO: error if size is larger than fixnum??
;  (let ((old-store (q:store q))
;        (new-store (make-vector (* (vector-length old-store) 2) #f)))
;    (q:set-size! q 0)
;    (let loop ((i (vector-length old-store)))
;      (when (not (zero? i))
;        (%queue-add! q (vector-ref 
;        (loop (- i 1)))))
)

;- queue-remove! - remove item (when to block? would be nice if we can block until an item becomes available)
;            maybe block by default, but have an optional timeout

;; TODO: queue-remove! which locks and call this function
(define (%queue-remove! q)
  (cond
    ((= (q:start q) (q:end q))
     (write "queue is already empty"))
    (else
      (let ((result (vector-ref (q:store q) (q:start q))))
        (q:set-start! q (inc (q:start q) (vector-length (q:store q))))
        result)))
)

;- queue-get - ?? 
;- queue-clear!
;- queue->list
;- queue-size (current length)
;- queue-capacity (max size until resize occurs)
;- queue-empty?

;(test-group "basic")
;(test #t (shared-queue? (make-queue)))
;(test-exit)
))