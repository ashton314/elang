#lang racket/base

(require racket/match)
(require racket/set)
(require racket/list)
(require "util.rkt")

(module+ test
  (require rackunit))

(provide lift-functions)

;; lift-functions :: expr, (λ₁, λ₂, ...) -> expr × ((atom, λ₁), (atom, λ₂), ...)
(define (lift-functions expr [fun-acc '()])
  (match expr
    [(? simple-exp?)
     (values expr fun-acc)]

    [`(primcall ,(? simple-exp?) ...)
     (values expr fun-acc)]

    [`(primcall ,(? simple-exp? simple) ... ,rst ...)
     (let-values ([(rst-lift rst-fns)
                   (for/lists (ae af)
                              ([r rst])
                     (lift-functions r))])
       (values `(primcall ,@simple ,@rst-lift) rst-fns))]

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
       (let ([f (gensym 'fn)]
             [frees (free-vars body (list->set params))])
         ;; Instances of a literal lambda get turned into a closure construction
         ;; TODO: I will want to replace the free-vars with indexes into the arg list of the closure struct
         (values `(closure ,f ,frees) (cons (cons f `(code ,frees ,params ,body-lift)) body-funcs))))]))

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

[module+ test
  (test-case "free variable analysis"
    (check-equal? '() (free-vars '(λ (x) (primcall + x 1))))
    (check-equal? '(y) (free-vars '(λ (x) (primcall + x y)))))

  (test-case "basic funciton lifting"
    (let-values ([(nexp _) (lift-functions '(λ (x) (primcall + x 1)))])
      (check-match nexp (list 'closure (? symbol?) '())))

    (let-values ([(nexp fns) (lift-functions '(fapp (λ (x) (primcall + x 1)) 42))])
      (check-match nexp (list 'fapp (list 'closure (? symbol?) '()) 42))
      (check-match fns (list (cons (? symbol?) '(code () (x) (primcall + x 1)))))))]

