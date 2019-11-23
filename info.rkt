#lang info
(define collection "casemate")
(define deps '("base" "srfi-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("casemate.scrbl" ())))
(define pkg-desc "Case converter in the style of camel-snake-kebab")
(define version "1.0.0")
(define pkg-authors '(jzp))
