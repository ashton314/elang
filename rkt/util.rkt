#lang racket/base

(provide (all-defined-out))

(define (simple-exp? e)
  (or (immediate? e) (symbol? e)))

(define (immediate? e)
  (or (number? e) (string? e)))

(define builins '(print-num print-str + - * /))

(define (builtin? sym)
  (memq sym builins))
