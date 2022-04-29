#lang racket/base

(require racket/match)
(require "util.rkt")

(provide alphatize ->cps)

;;; CPS conversion module

(define (->cps expr [κ 'κ₀])
  (match expr
    [(? simple-exp? e) `(,κ ,e)]

    [`(app ,(? simple-exp? f))
     `(fapp ,f ,κ)]

    [`(app ,(? simple-exp? f) ,args ...)
     ;; cps args and then call

     (define (cps-args cpsd todo)
       (if (null? todo)
           `(fapp ,f ,@cpsd ,κ)
           (if (simple-exp? (car todo))
               (cps-args (cons (car todo) cpsd) (cdr todo))
               ;; convert head of todo
               (->cps (car todo)
                      (let ([k-fresh (gensym 'κ)])
                        `(λ (,k-fresh)
                           ,(->cps `(app ,f ,@cpsd ,k-fresh ,@(cdr todo)))))))))
     (cps-args '() args)]

    [`(app ,f ,as ...)
     (->cps f (let ([k-fresh (gensym 'κ)])
                `(λ (,k-fresh) ,(->cps `(app ,k-fresh ,@as)))))]

    [`(,(or 'lambda 'λ) (,params ...) ,body)
     (let ([k1 (gensym 'κ)])
       `(kapp ,κ (λ (,@params ,k1)
              ,(->cps body k1))))]

    [`(if ,tst ,tc ,fc)
     (let ([k1 (gensym 'κ)]
           [ctc (->cps tc κ)]
           [cfc (->cps fc κ)])
       (->cps tst `(λ (,k1) (if ,k1 ,ctc ,cfc))))]))

(define (alphatize expr [var-map (make-hash)])
  (match expr
    [(? symbol? e)
     (hash-ref var-map e)]
    ;; FIXME
    ))
