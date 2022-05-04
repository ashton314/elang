#lang racket/base

(require "util.rkt")
(require "cps.rkt")
(require "codegen.rkt")

(provide compile-program output-file)

(define output-file (make-parameter "a.c"))

(define (compile-program prog)
  (let* ([cpsd (->cps prog)])
    (emit-program (output-file) cpsd)))
