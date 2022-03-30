#lang racket

(provide (all-defined-out))

;;; CPS conversion module

(define (->cps expr [κ 'κ₀])
  (match expr
    [(? symbol? e) `(,κ ,e)]
    [(? number? e) `(,κ ,e)]
    ;; [`(app ,f)
    ;;  ]
    ;; [`(app ,f ,as ...)
    ;;  ]
    [`(,(or 'lambda 'λ) (,params ...) ,body)
     (let ([k1 (gensym 'κ)])
       `(kapp ,κ (λ (,@params ,k1)
              ,(->cps body k1))))]
    [`(if ,tst ,tc ,fc)
     (let ([k1 (gensym 'κ)]
           [ctc (->cps tc κ)]
           [cfc (->cps fc κ)])
       (->cps tst `(λ (,k1) (if ,k1 ,ctc ,cfc))))]))
