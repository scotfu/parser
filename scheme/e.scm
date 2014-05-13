#! /usr/local/bin/guile -s
!#

(define raise
  (lambda (exn)
    ((current-exception-handler) exn)))

(define-syntax with-handlers
  (syntax-rules ()
    ((_ ((predicate handler-procedure) ...) b1 b2 ...)
     ((call-with-current-continuation
        (lambda (k)
          (parameterize ((current-exception-handler
                          (let ((rh (current-exception-handler))
                                (preds (list predicate ...))
                                (handlers (list handler-procedure ...)))
                            (lambda (exn)
                              (parameterize ((current-exception-handler rh))
                                (let f ((preds preds) (handlers handlers))
                                  (if (not (null? preds))
                                      (if ((car preds) exn)
                                          (k (lambda () ((car handlers) exn)))
                                          (f (cdr preds) (cdr handlers))))))
                              (rh exn)))))
            (call-with-values
              (lambda () b1 b2 ...)
              (lambda args (k (lambda () (apply values args))))))))))))
(define-syntax with-rec-handlers
  (syntax-rules ()
    ((_ ((predicate handler-procedure) ...) b1 b2 ...)
     ((call-with-current-continuation
        (lambda (k)
          (letrec
            ((new-rh
               (let ((rh (current-exception-handler))
                     (preds (list predicate ...))
                     (handlers (list handler-procedure ...)))
                 (lambda (exn)
                   (parameterize ((current-exception-handler rh))
                     (let f ((preds preds) (handlers handlers))
                       (if (not (null? preds))
                           (if ((car preds) exn)
                               (k (lambda ()
                                    (parameterize ((current-exception-handler
                                                     new-rh))
                                      ((car handlers) exn))))
                               (f (cdr preds) (cdr handlers))))))
                   (rh exn)))))
            (parameterize ((current-exception-handler new-rh))
              (call-with-values
                (lambda () b1 b2 ...)
                (lambda args (k (lambda () (apply values args)))))))))))))

(define-syntax with-continuing-handlers
  (syntax-rules ()
    ((_ ((predicate handler-procedure) ...) b1 b2 ...)
     ((call-with-current-continuation
        (lambda (k)
          (parameterize
            ((current-exception-handler
               (let ((rh (current-exception-handler))
                     (preds (list predicate ...))
                     (handlers (list handler-procedure ...)))
                 (lambda (exn)
                   (call-with-current-continuation
                     (lambda (k1)
                       (parameterize ((current-exception-handler rh))
                         (let f ((preds preds) (handlers handlers))
                           (if (not (null? preds))
                               (if ((car preds) exn)
                                   (k (lambda ()
                                        (k1 ((car handlers) exn))))
                                   (f (cdr preds) (cdr handlers))))))
                       (rh exn)))))))
            (call-with-values
              (lambda () b1 b2 ...)
              (lambda args (k (lambda () (apply values args))))))))))))
(define mine
(lambda (x)
  (begin
    (raise 1)
)

)
)
