#lang racket/base

(require racket/match)
(require "util.rkt")

(provide lift-functions)

;; Note: since we're moving code around here, the program *must* be
;; alphatized so the variables line up to the right references.
;; lift-functions :: expr, (λ₁, λ₂, ...) -> expr × ((atom, λ₁), (atom, λ₂), ...)
(define (lift-functions expr [fun-acc '()])
  (match expr
    [(? simple-exp?)
     (values expr fun-acc)]

    [`(,(? symbol? (or 'fapp 'kapp) app-type) ,fn ,as ...)
     (let-values ([(fn-lft fn-fns) (lift-functions fn)]
                  [(args-lft args-fns)
                   (for/lists (ae af)
                              ([a as])
                     (lift-functions a))])
       (values `(,app-type ,fn-lft ,@args-lft)
               (cons fn-fns args-fns)))]

    [`(,(or 'lambda 'λ) (,params ...) ,body)
     (let-values ([(body-lift body-funcs) (lift-functions body)])
       (let ([f (gensym 'φ)])
         (values f (cons (cons f `(λ ,params ,body-lift)) body-funcs))))]))
