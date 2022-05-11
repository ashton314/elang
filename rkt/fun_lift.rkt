#lang racket/base

(require racket/match)
(require racket/set)
(require racket/list)
(require "util.rkt")

(provide lift-functions)

;; lift-functions :: expr, (λ₁, λ₂, ...) -> expr × ((atom, λ₁), (atom, λ₂), ...)
(define (lift-functions expr [fun-acc '()])
  (match expr
    [(? simple-exp?)
     (values expr fun-acc)]

    [`(primcall ,(? simple-exp?) ...)
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

(define (set-add-all setname lst)
  (foldl (λ (i acc) (set-add acc i)) setname lst))

;;; free-vars: return variables that appear free in the body of an expression
(define (free-vars expr [bound-vars (set)])
  (match expr
    [(? symbol?) (if (set-member? bound-vars expr) '() (list expr))]

    [(? simple-exp?) '()]

    [`(λ (,binds ...) ,body)
     (free-vars body (set-add-all bound-vars binds))]

    [`(primcall ,_ ,rst ...)
     (append-map (λ (i) (free-vars i bound-vars)) rst)]

    [`(,(or 'if 'app) ,rst ...)
     (append-map (λ (i) (free-vars i bound-vars)) rst)]))
