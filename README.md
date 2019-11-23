# Casemate

Johan Persson \(jzp\) <johan at 2130 dot se>

## 1. Synopsis

`casemate` is a utility library for converting strings, symbols and
byte-strings to various populat case-styles. It’s modeled after the
excellent Clojure library
[camel-snake-kebab](https://github.com/clj-commons/camel-snake-kebab).

## 2. Reference

```racket
 (require casemate) package: [casemate](https://pkgs.racket-lang.org/package/casemate)
```

Each of the following procedures take a string-like piece of data and
converts it to the corresponding style.

```racket
(->PascalCase string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->Camel_Snake_Case string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->camelCase string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->SCREAMING_SNAKE_CASE string-like)
 -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->snake_case string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->kebab-case string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->SCREAMING-KEBAB-CASE string-like)
 -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

```racket
(->HTTP-Case string-like) -> (or/c symbol? string? bytes)
  string-like : (or/c symbol? string? bytes?)
```

This is an odd one: it performs a lookup on special words that require a
canonical casing, use them if they match, otherwise will fall back on
`string-titlecase`.

## 3. Copyright & License

Copyright © 2019 Johan Persson.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or \(at
your option\) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
General Public License for more details.

You should have received copies of the GNU General Public License and
the GNU Lesser General Public License along with this program. If not,
see [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/).
