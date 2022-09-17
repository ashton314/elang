#lang racket/base

(require racket/match)
(require racket/pretty)
(require "util.rkt")

(provide code->c emit-program)

(define (code->c emit expr ret)
  (match expr
    [(? immediate?)
     (emit (return expr ret))]

    ;; special cased for now; we'll want to generalize calls to
    ;; builtins at some point
    [`(primcall print-num ,(? simple-exp? e) ,_)
     (emit (format "printf(\"%d\", ~a);" e))]

    [`(primcall print-str ,(? simple-exp? e) ,_)
     (emit (format "printf(\"%s\", ~a);" e))]

    [`(primcall + ,a ,b ,cont)
     (let ([tmp (gensym 'i)])
       (emit (format "int ~a = ~a + ~a;" tmp a b))
       (emit-funcall emit cont (list tmp)))]
    ))

(define (return val ret-var)
  (format "~a = ~a;" val ret-var))

(define (emit-funcall emit closure-ref args)
  (match closure-ref
    [`(closure ,fnref ,closed-over-vals)
     (let ([closure-varname (gensym 'closure)])
       (emit-closure emit fnref closed-over-vals closure-varname))]))

(define (emit-closure emit fnname closed-list result-varname)
  (emit (format "struct closure *~a = malloc(sizeof(struct closure));" result-varname))

  (let ([closed-list-var (gensym 'closed_vars)])
    (emit (format "void** ~a = malloc(sizeof(void*) * ~a;"
                  closed-list-var (length closed-list)))
    (for ([i (in-range (length closed-list))]
          [a closed-list])
      ;; help! assuming just integers here!
      (emit (format "~a[~a] = malloc(sizeof(int)); *~a[~a] = ~a;"
                    closed-list-var i closed-list-var i a)))
    (emit (format "~a->closed_args = ~a;" result-varname closed-list-var))
    (emit (format "~a->closed_args_c = ~a;" result-varname (length closed-list)))
    (emit (format "~a->code = &~a;" result-varname fnname))))

(define (emit-closure-use emit closure-varname arg-list result-varname)
  (let ([arg-list-name (gensym 'arg_list)])
    (emit (format "void** ~a = malloc(sizeof(void*) * ~a;"
                  arg-list-name (length arg-list)))
    (for ([i (in-range (length arg-list))]
          [a arg-list])
      (emit (format "~a[~a] = malloc(sizeof(int)); *~a[~a] = ~a;"
                    arg-list-name i arg-list-name i a)))
    (emit (format "int ~a = *(int *)~a->code(~a->closed_args, ~a);"
                  result-varname closure-varname closure-varname arg-list-name))))

(define (emit-headers emit)
  (emit "#include <stdio.h>")
  (emit "#include \"elang_core.h\"")
  (emit "int __os_return() { exit; }"))

(define (emit-main emit body)
  (emit "int main(int argc, char* argv[]) {")
  (emit "int main_exit = 0;")
  (body emit)
  (emit "return main_exit;")
  (emit "}"))

(define (emit-program filename prog)
  (with-output-to-file filename
    #:exists 'replace
    (λ ()
      (let ([emit displayln])
        (emit-headers emit)
        (emit-main emit (λ (e)
                          (code->c e prog "main_exit")))))))
