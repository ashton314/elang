#lang racket/base

(require racket/match)
(require "util.rkt")

(provide alphatize ->cps)

;;; CPS conversion module

(define (cps-args source-form-name dest-form-name form-var cpsd todo κ)
  (if (null? todo)
      `(,dest-form-name ,form-var ,@cpsd ,κ)
      (if (simple-exp? (car todo))
          (cps-args source-form-name dest-form-name form-var (cons (car todo) cpsd) (cdr todo) κ)
          ;; convert head of todo
          (->cps (car todo)
                 (let ([k-fresh (gensym 'κ)])
                   `(λ (,k-fresh)
                      ,(->cps `(,source-form-name ,form-var ,@cpsd ,k-fresh ,@(cdr todo)) κ)))))))

(define (->cps expr κ)
  (match expr
    [(? simple-exp? e) `(,κ ,e)]

    [`(primcall ,op ,args ...)
     (cps-args 'primcall 'primcall op '() (reverse args) κ)]

    [`(app ,(? simple-exp? f))
     `(fapp ,f ,κ)]

    [`(app ,(? simple-exp? f) ,args ...)
     ;; cps args and then call
     (cps-args 'app 'fapp f '() args κ)]

    [`(app ,f ,as ...)
     (->cps f (let ([k-fresh (gensym 'κ)])
                `(λ (,k-fresh) ,(->cps `(app ,k-fresh ,@as) κ))))]

    [`(,(or 'lambda 'λ) (,params ...) ,body)
     (let ([k1 (gensym 'κ)])
       `(kapp ,κ (λ (,@params ,k1)
              ,(->cps body k1))))]

    [`(let* ([,(? symbol? varname) ,binding] ...) ,body)
     ;; let* will get completely compiled out
     (define (loop vars binds)
       (if (null? vars)
           (->cps body κ)
           (->cps (car binds) `(λ (,(car vars)) ,(loop (cdr vars) (cdr binds))))))
     (loop varname binding)]

    [`(if ,tst ,tc ,fc)
     (let ([k1 (gensym 'κ)]
           [ctc (->cps tc κ)]
           [cfc (->cps fc κ)])
       (->cps tst `(λ (,k1) (if ,k1 ,ctc ,cfc))))]))

#;
(define (alphatize expr [var-map (make-hash)])
  (match expr
    [(? symbol? e)
     (hash-ref var-map e)]
    ;; FIXME
    ))
(define (alphatize) 'noop)
