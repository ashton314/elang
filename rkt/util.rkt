#lang racket/base

(provide (all-defined-out))

(define (simple-exp? e)
  (or (number? e) (symbol? e)))
