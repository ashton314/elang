#lang racket

(provide (all-defined-out))

;;; CPS conversion module

(define (->cps expr κ)
  (match expr
    [(? symbol? e) `(,κ ,e)]
    [(? number? e) `(,κ ,e)]
    [`(if ,tst ,tc ,fc)
     (let ([k1 (gensym 'κ)]
           [ctc (->cps tc κ)]
           [cfc (->cps fc κ)])
       (->cps tst `(λ (,k1) (if ,k1 ,ctc ,cfc))))]))
