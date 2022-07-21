#lang racket/base

(require racket/match)
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
     (emit (format "printf(\"%s\", ~a);" e))]))

(define (return val ret-var)
  (format "~a = ~a;" val ret-var))

(define (emit-headers emit)
  (emit "#include <stdio.h>")
  (emit "#include \"elang_core.h\""))

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
