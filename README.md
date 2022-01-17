# elm-ra

Ra supports Pointfree style in Elm by providing various combinators to work with Predicates, Relations, Math, Functions, and Flow Control.

Pointfree can be abused, but when it is appropriate pointfree style is

- More Readable & Literate. The declaration of the lambda with an argument and repetitious application of the argument can obscure the meaning.
- Safer. It is impossible to inadvertently pass the wrong value because functions are only composed and not applied or called.el

## Categories

### Predicate Combinators

@docs allPass, anyPass, both, either, complement, false, true

### Chain and Composition Friendly Relations

@docs lessThan, lessThanEqualTo, greaterThan, greaterThanEqualTo, equals

### Chain and Composition Friendly Math

@docs adding, subtracting, dividedByInt, dividedByFloat, multiplying, negated

### Flow Control

@docs ifElse, cond, condDefault, when, unless, until

### Function Combinators

@docs converge, converge3, convergeList, curry, curry3, flip, fnContraMap, fnContraMap2, fnContraMap3, uncurry, uncurry3

## Name and Relation to RamdaJS

Ra is a subset of RamdaJS converted to Elm and excluding functions relating to topics indicated below. I originally toyed with naming this package simply R but that would create confusion with the R language.

### Excellent elm-community Extra packages such as

Many of the RamdaJS functions or their equivalent functionality can be found in these packages.

- [Maybe.Extra](https://package.elm-lang.org/packages/elm-community/maybe-extra/latest/)
- [List.Extra](https://package.elm-lang.org/packages/elm-community/list-extra/latest/)
  - aperture is [groupsOfWithStep](https://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#groupsOfWithStep)
- [Dict.Extra](https://package.elm-lang.org/packages/elm-community/dict-extra/latest/)
  - [groupBy](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#groupBy)
  - indexedBy is [fromListBy](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#fromListBy)
  - countBy is one List.map away from [frequencies](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#frequencies)

## Object Meta-Programming

RamdaJS features a number of functions to manipulate JavaScript objects. The closest equivalent in Elm would be Dict which already features all of the necessary functions
either through Core or Dict.Extra. Further, Dict is not the same as Record and has a number of tradeoffs when compared to Records

- lose of explicit type contract
  - requiring neurotic optionality checks (i.e. Dict.get returns a Maybe)
- a Dict can only hold values of a single type while a Record may feature a different type for each field.

### Relating to Optics (Lens)

There are several high quality Elm packages that provide optics.

### Higher-Kinded Types and Categories

Elm does not feature higher kinded types or typeclasses and so we cannot express abstract

- `map` (Functor)
- `chain` (Monad)
- `append` (Monoid)
- `sequence`/`traverse` (Applicative, Traversable).

**NOTE** We get better error messages, fewer opportunities for ambiguous code, and, very likely, a faster compiler in the exchange.
