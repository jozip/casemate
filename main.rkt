#lang racket/base

;;;; Casemate
;;;;
;;;; A utility for converting strings, symbols and byte-strings to various
;;;; popular case-styles. Modeled after the excellent Clojure library
;;;; camel-snake-kebab (https://github.com/clj-commons/camel-snake-kebab).
;;;;
;;;; Copyright (C) 2019 Johan Persson <johan@2130.se>
;;;;
;;;; This program is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation, either version 3 of the
;;;; License, or (at your option) any later version.
;;;;
;;;; This program is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU Lesser General Public License for more details.
;;;;
;;;; You should have received copies of the GNU General Public License
;;;; and the GNU Lesser General Public License along with this program.
;;;; If not, see <https://www.gnu.org/licenses/>.


;;;; Imports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require racket/list
         racket/string
         racket/bytes
         racket/function
         racket/contract)

(require srfi/26) ;; For the handy cut-function


;;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; List of special words in HTTP headers.
;;; Made into an association list for quick lookup.
(define http-header-special-words
  (map (lambda (component)
         (cons (string-downcase component) component))
       '("MD5"
         "HTTP2"
         "TE"
         "DNT"
         "ATT"
         "UIDH"
         "XSRF"
         "CSRFToken"
         "ETag"
         "P3P"
         "WWW"
         "CSP"
         "ID"
         "UA"
         "XSS"
         "SSL"
         "HTTP"
         "HTTPS"
         "IM"
         "WAP")))


;;;; Utility functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Splits a string on lower-case/upper-case character-pairs without
;;; consuming them.
(define (string-split-by-case str)
  (let ([components null]
        [buffer null])
    (for ([char (string->list str)])
         (when (and (not (null? buffer))
                    (char-lower-case? (car buffer))
                    (char-upper-case? char))
               (set! components (cons (reverse buffer) components))
               (set! buffer null))
         (set! buffer (cons char buffer)))
    (reverse (map list->string (cons (reverse buffer) components)))))

;;; Applies a list of splitter-functions to a string.
(define (string-split/functions str [splitters (list string-split)])
  (define (runner strs splitters)
    (if (null? splitters)
        strs
        (runner (flatten (map (car splitters) strs)) (cdr splitters))))
  (runner (list str) splitters))


;;;; Core functionality ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Splits a string with common separators, casing and whitespace.
(define (split str)
  (string-split/functions str (list string-split
                                    (cut string-split <> "-")
                                    (cut string-split <> "_")
                                    string-split-by-case)))

;;; Joins a list of string components with a given separator string.
;;; `car-case` is the case-function for the car of the components, and
;;; `cdr-case` what is used for the rest of the list.
(define (join car-case cdr-case separator components)
  (string-join (cons (car-case (car components))
                     (map cdr-case (cdr components)))
               separator))

;;; HTTP header case converter.
(define (http-case str)
  (let ([special (assoc (string-downcase str) http-header-special-words)])
    (if (eq? special #f)
      (string-titlecase str)
      (cdr special))))

;;; Converts symbols and byte-strings to strings and back.
;;; Throws an exception if the given data is nonsense.
(define (->string-> thing-applier thing)
  (cond [(symbol? thing)
         ((compose string->symbol thing-applier symbol->string) thing)]
        [(bytes? thing)
         ((compose string->bytes/utf-8 thing-applier bytes->string/utf-8) thing)]
        [(string? thing) (thing-applier thing)]
        [else
          (error "it makes no sense to case convert for the given data")]))

;;; Maker for a converter function
(define (make-converter car-case cdr-case separator)
  (curry ->string-> (compose (curry join car-case cdr-case separator) split)))

;;; Converter functions
(define ->PascalCase           (make-converter string-titlecase string-titlecase "" ))
(define ->Camel_Snake_Case     (make-converter string-titlecase string-titlecase "_"))
(define ->camelCase            (make-converter string-downcase  string-titlecase "" ))
(define ->SCREAMING_SNAKE_CASE (make-converter string-upcase    string-upcase    "_"))
(define ->snake_case           (make-converter string-downcase  string-downcase  "_"))
(define ->kebab-case           (make-converter string-downcase  string-downcase  "-"))
(define ->SCREAMING-KEBAB-CASE (make-converter string-upcase    string-upcase    "-"))
(define ->HTTP-Case            (make-converter http-case        http-case        "-"))


;;;; Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define converter/c (-> (or/c symbol? string? bytes?) any/c))

(provide (contract-out
           [->PascalCase           converter/c]
           [->Camel_Snake_Case     converter/c]
           [->camelCase            converter/c]
           [->SCREAMING_SNAKE_CASE converter/c]
           [->snake_case           converter/c]
           [->kebab-case           converter/c]
           [->SCREAMING-KEBAB-CASE converter/c]
           [->HTTP-Case            converter/c]))


;;;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(module+ test
  (require rackunit)

  (test-case
    "Procedure: string-split-by-case"
    (check-equal? (string-split-by-case "aB")
                  '("a" "B")
                  "should split in the boundary between 'a' and 'B'")
    (check-equal? (string-split-by-case "AB")
                  '("AB")
                  "should not split the string")
    (check-equal? (string-split-by-case "Ab")
                  '("Ab")
                  "should not split the string")
    (check-equal? (string-split-by-case "ab")
                  '("ab")
                  "should not split the string"))

  (test-case
    "Procedure: string-split/functions"
    (check-equal? (string-split/functions "a:b/c" (list (cut string-split <> "/")
                                                        (cut string-split <> ":")))
                  '("a" "b" "c")
                  "should split the string with the supplied splitters")
    (check-equal? (string-split/functions "a b" null)
                  '("a b")
                  "should not split the string if no splitter functions are supplied"))

  (test-case
    "Procedure: split"
    (check-equal? (split "a-bC_d e")
                  '("a" "b" "C" "d" "e")
                  "should split a string with the common separators, including whitespace"))

  (test-case
    "Procedure: join"
    (check-equal? (join string-titlecase string-upcase "beep" '("FOO" "bar" "Thud"))
                  "FoobeepBARbeepTHUD"
                  "should join string components with the given first-component transform, rest-component transform and separator string"))

  (test-case
    "Procedure: ->string->"
    (check-equal? (->string-> identity 'foo)
                  'foo
                  "should convert symbol to string and back")
    (check-equal? (->string-> identity "foo")
                  "foo"
                  "should convert accept string as is")
    (check-equal? (->string-> identity #"foo")
                  #"foo"
                  "should convert byte string to string and back")
    (check-exn exn:fail? (lambda () (->string-> identity 123))
               "should fail when given nonsense data"))

  (test-case
    "Procedure: http-case"
    (check-equal? (http-case "Http")
                  "HTTP"
                  "should return upper-cased string for a special word")
    (check-equal? (http-case "foo")
                  "Foo"
                  "should return title-cased string for an ordinary word"))

  (test-case
    "Check that each converter returns the expected result for a given string"
    (define test-string "fooBar-thud_grunt beepHTTP")
    (check-equal? (->PascalCase test-string)
                  "FooBarThudGruntBeepHttp")
    (check-equal? (->Camel_Snake_Case test-string)
                  "Foo_Bar_Thud_Grunt_Beep_Http")
    (check-equal? (->camelCase test-string)
                  "fooBarThudGruntBeepHttp")
    (check-equal? (->SCREAMING_SNAKE_CASE test-string)
                  "FOO_BAR_THUD_GRUNT_BEEP_HTTP")
    (check-equal? (->snake_case test-string)
                  "foo_bar_thud_grunt_beep_http")
    (check-equal? (->kebab-case test-string)
                  "foo-bar-thud-grunt-beep-http")
    (check-equal? (->SCREAMING-KEBAB-CASE test-string)
                  "FOO-BAR-THUD-GRUNT-BEEP-HTTP")
    (check-equal? (->HTTP-Case test-string)
                  "Foo-Bar-Thud-Grunt-Beep-HTTP"))

  (test-case
    "Check that each converter returns the expected result for a given symbol"
    (define test-symbol '|fooBar-thud_grunt beepHTTP|)
    (check-equal? (->PascalCase test-symbol)
                  'FooBarThudGruntBeepHttp)
    (check-equal? (->Camel_Snake_Case test-symbol)
                  'Foo_Bar_Thud_Grunt_Beep_Http)
    (check-equal? (->camelCase test-symbol)
                  'fooBarThudGruntBeepHttp)
    (check-equal? (->SCREAMING_SNAKE_CASE test-symbol)
                  'FOO_BAR_THUD_GRUNT_BEEP_HTTP)
    (check-equal? (->snake_case test-symbol)
                  'foo_bar_thud_grunt_beep_http)
    (check-equal? (->kebab-case test-symbol)
                  'foo-bar-thud-grunt-beep-http)
    (check-equal? (->SCREAMING-KEBAB-CASE test-symbol)
                  'FOO-BAR-THUD-GRUNT-BEEP-HTTP)
    (check-equal? (->HTTP-Case test-symbol)
                  'Foo-Bar-Thud-Grunt-Beep-HTTP))

  (test-case
    "Check that each converter returns the expected result for a given byte string"
    (define test-byte-string #"fooBar-thud_grunt beepHTTP")
    (check-equal? (->PascalCase test-byte-string)
                  #"FooBarThudGruntBeepHttp")
    (check-equal? (->Camel_Snake_Case test-byte-string)
                  #"Foo_Bar_Thud_Grunt_Beep_Http")
    (check-equal? (->camelCase test-byte-string)
                  #"fooBarThudGruntBeepHttp")
    (check-equal? (->SCREAMING_SNAKE_CASE test-byte-string)
                  #"FOO_BAR_THUD_GRUNT_BEEP_HTTP")
    (check-equal? (->snake_case test-byte-string)
                  #"foo_bar_thud_grunt_beep_http")
    (check-equal? (->kebab-case test-byte-string)
                  #"foo-bar-thud-grunt-beep-http")
    (check-equal? (->SCREAMING-KEBAB-CASE test-byte-string)
                  #"FOO-BAR-THUD-GRUNT-BEEP-HTTP")
    (check-equal? (->HTTP-Case test-byte-string)
                  #"Foo-Bar-Thud-Grunt-Beep-HTTP")))

;;                                  ❦ ❦ ❦                                   ;;
;;                                   ❦ ❦                                    ;;
;;                                    ❦                                     ;;

