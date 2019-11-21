#lang scribble/manual
@require[@for-label[casemate]]

@title{Casemate}
@author[(author+email "Johan Persson (jzp)" "johan@2130.se" #:obfuscate? #t)]

@section{Synopsis}

@racketmodname[casemate] is a utility library for converting strings, symbols
and byte-strings to various populat case-styles. It's modeled after the
excellent Clojure library @hyperlink["https://github.com/clj-commons/camel-snake-kebab" "camel-snake-kebab"].

@section{Reference}

@defmodule[casemate]

Each of the following procedures take a string-like piece of data
and converts it to the corresponding style.

@defproc[(->PascalCase [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->Camel_Snake_Case [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->camelCase [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->SCREAMING_SNAKE_CASE [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->snake_case [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->kebab-case [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@defproc[(->SCREAMING-KEBAB-CASE [string-like (or/c symbol? string? bytes?)])
         (or/c symbol? string? bytes)]

@section{Copyright & License}

Copyright © 2019 Johan Persson.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received copies of the GNU General Public License
and the GNU Lesser General Public License along with this program.
If not, see @hyperlink["https://www.gnu.org/licenses/" "https://www.gnu.org/licenses/"].

