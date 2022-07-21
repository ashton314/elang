#lang racket/base

(require "util.rkt")
(require "cps.rkt")
(require "fun_lift.rkt")
(require "codegen.rkt")

(require racket/pretty)

(provide compile-program output-file)

(define output-file (make-parameter "a.c"))

(define (compile-program prog)
  (let*-values ([(cpsd) (->cps prog)]
                [(progn funcs) (lift-functions cpsd)])
    (pretty-print cpsd)
    (pretty-print progn)
    (pretty-print funcs)
    (emit-program (output-file) cpsd)))
