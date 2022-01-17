module Ra exposing
    ( allPass, anyPass, both, either, complement, false, true
    , lessThan, lessThanEqualTo, greaterThan, greaterThanEqualTo, equals
    , adding, subtracting, dividedByInt, dividedByFloat, multiplying, negated
    , ifElse, cond, condDefault, when, unless, until
    , converge, converge3, convergeList, curry, curry3, flip, fnContraMap, fnContraMap2, fnContraMap3, uncurry, uncurry3
    , isMemberOf, deduplicateConsecutiveItemsBy
    )

{-| Ra supports Pointfree style in Elm by providing various combinators to work with Predicates, Relations, Math, Functions, and Flow Control.

Pointfree can be abused, but when it is appropriate pointfree style is

  - More Readable & Literate. The declaration of the lambda with an argument and repetitious application of the argument can obscure the meaning.
  - Safer. It is impossible to inadvertently pass the wrong value because functions are only composed and not applied or called.el


### Predicate Combinators

@docs allPass, anyPass, both, either, complement, false, true


### Chain and Composition Friendly Relations

@docs lessThan, lessThanEqualTo, greaterThan, greaterThanEqualTo, equals, is


### Chain and Composition Friendly Math

@docs adding, subtracting, dividedByInt, dividedByFloat, multiplying, negated


### Flow Control

@docs ifElse, cond, condDefault, when, unless, until


### Function Combinators

@docs converge, converge3, convergeList, curry, curry3, flip, fnContraMap, fnContraMap2, fnContraMap3, uncurry, uncurry3


## Name and Relation to RamdaJS

Ra is a subset of RamdaJS converted to Elm and excluding functions relating to topics indicated below. I originally toyed with naming this package simply R but that would create confusion with the R language.


## Miscellaneous

@docs isMemberOf, deduplicateConsecutiveItemsBy


### Excellent elm-community Extra packages such as

Many of the RamdaJS functions or their equivalent functionality can be found in these packages.

  - [Maybe.Extra](https://package.elm-lang.org/packages/elm-community/maybe-extra/latest/)
  - [List.Extra](https://package.elm-lang.org/packages/elm-community/list-extra/latest/)
      - aperture is [groupsOfWithStep](https://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#groupsOfWithStep)
  - [Dict.Extra](https://package.elm-lang.org/packages/elm-community/dict-extra/latest/)
      - [groupBy](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#groupBy)
      - indexedBy is [fromListBy](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#fromListBy)
      - countBy is one List.map away from [frequencies](https://package.elm-lang.org/packages/elm-community/dict-extra/2.4.0/Dict-Extra#frequencies)


### Object Meta-Programming

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

-}

import Dict
import List.Extra



-- ------------------------------------------------------------------------------
-- Dictionary
-- ------------------------------------------------------------------------------


{-| Dict.member with the arguments flipped in order to test the member of _many_ keys against a _single_ dictionary.

    let
        validPersonIds =
            personIds
            |> List.filter (isMemberOf idToPerson)
    in
    -- ...

-}
isMemberOf : Dict.Dict comparable v -> comparable -> Bool
isMemberOf =
    flip Dict.member



-- ------------------------------------------------------------------------------
-- List
-- ------------------------------------------------------------------------------


{-| Deduplicate consecutive items in a list using a function to extra the element of interest.

    deduplicateConsecutiveItemsBy identity [ 1, 1, 1, 2, 3, 3 ] -- [1, 2, 3]

    deduplicateConsecutiveItemsBy
        Tuple.second
        [ ("Betty", 1), ("Tom", 1), ("Jane", 2)] -- [("Betty", 1), ("Jane", 2)]

-}
deduplicateConsecutiveItemsBy : (a -> b) -> List a -> List a
deduplicateConsecutiveItemsBy key =
    List.Extra.groupWhile (fnContraMap2 key equals)
        >> List.map Tuple.first



-- ------------------------------------------------------------------------------
-- Function
-- ------------------------------------------------------------------------------


{-| Flip the first and second arguments of a function.

  - This is an incredibly useful function when needing to change the application of an existing function.
  - **WARNING** However, it can also destroy the literate reading of code if overused and it is easy to overuse.

For example, the first argument to Dict.get is the key and the second is the dictionary.
What if we want to map over multiple keys? We would want to apply the dictionary first and get a function that accepts the key.

    valuesForKeys : Dict comparable value -> List comparable -> List value
    valuesForKeys =
        flip Dict.get >> List.filterMap

More simply, consider the case of having a `(Dictionary k v)` of values but wanting to pass along a function `k -> Maybe v` to some provider
so that the provider doesn't couple to the Dictionary? This would be a good idea to Reduce Coupling and honor the Principle of Least Privilege.

    someInterestingProvider : (Int -> Widget) -> String -> Maybe Widget
    someInterestingProvider = Debug.todo "doesn't matter for the demonstration"

    someConsumer : List Widget -> String -> Maybe Widget
    someConsumer widgets =
        someInterestingProvider (flip Dict.get (indexBy .id widgets))

-}
flip : (a -> b -> c) -> (b -> a -> c)
flip f a b =
    f b a


{-| Converts a function from 2-tuple to normal curried function. This is mostly useful for reverting an uncurry.
-}
curry : (( a, b ) -> c) -> (a -> b -> c)
curry original =
    \a -> \b -> original ( a, b )


{-| Converts a function from 3-tuple to normal curried function. This is mostly useful for reverting an uncurry.
-}
curry3 : (( a, b, c ) -> d) -> (a -> b -> c -> d)
curry3 original =
    \a -> \b -> \c -> original ( a, b, c )


{-| Converts a normal Elm function to a function that accepts a 2-tuple. This can be useful if the output of some function happens to be
a tuple or a functor (List, Maybe, Result, etc.) of a tuple.

    sums : List (number, number) -> List number
    sums = List.map (uncurry adding)

    sum : Maybe (number, number) -> Maybe number
    sum = Maybe.map (uncurry adding)

-}
uncurry : (a -> b -> c) -> (( a, b ) -> c)
uncurry original =
    \( a, b ) -> original a b


{-| Converts a standard Elm function to a function that accepts a 3-tuple.
-}
uncurry3 : (a -> b -> c -> d) -> (( a, b, c ) -> d)
uncurry3 original =
    \( a, b, c ) -> original a b c


{-| This function can best be explained with examples as it is unusually useful when building data pipelines but has a tricky type signature.

Please do NOT be afraid of the type signature!

If you would like a function that transforms a Person to a String of their first and last name.

    converge
        String.append
        ( .firstName, .lastName >> String.append " " )

Or perhaps you are building a data pipeline

  - where at some stage you have a `List Widget`
  - and you have a function `extraWidgets: List Widget -> List Widget`
  - and you would like to like to end up with a new list of widgets that contains both the original widgets and the extra widgets.

Then you might write

    converge
        List.append
        (identity, extraWidgets)

-}
converge : (first -> second -> output) -> ( input -> first, input -> second ) -> input -> output
converge fn ( firstFn, secondFn ) input =
    fn (firstFn input) (secondFn input)


{-| Converge for the case of a 3 argument function. See `converge` for examples.
-}
converge3 : (first -> second -> third -> output) -> ( input -> first, input -> second, input -> third ) -> input -> output
converge3 fn ( firstFn, secondFn, thirdFn ) input =
    fn (firstFn input) (secondFn input) (thirdFn input)


{-| As with converge, convergeList is best explained with an example

    convergeList
        (String.join " ")
        [ .firstName, .middleInitial, .lastName ]

Or to be more complete

    nonEmptyStrings : List String -> List String
    nonEmptyStrings = List.filter (complement String.isEmpty)

    fullName : Person -> String
    fullName =
        convergeList
            (nonEmptyStrings >> String.join " ")
            [ .firstName, .middleInitial, .lastName ]

-}
convergeList : (List a -> output) -> List (input -> a) -> input -> output
convergeList reducer reducerInputs input =
    reducerInputs |> List.map ((|>) input) |> reducer


{-| This is like `map` for functions but going the opposite direction (contra functor).

  - map: (a -> b) -> F a -> F b
  - contraMap: (a -> b) -> F b -> F a

OKAY. So that it probably a little or a lot confusing. How would you use this? Any time yout have a parent/child relation and a function that
will transform the child and you want to get back a function that transforms the parent.

    addressesCount : Person -> Int
    addressesCount = fnContraMap .addresses List.length

-}
fnContraMap : (a -> b) -> (b -> c) -> (a -> c)
fnContraMap ab original =
    ab >> original


{-| Best described with an example. Let's say you have a parent/child relation, a function of 2 arguments that applies to the child type
and you would like to get back a function that works on the parent.

    sameFavoriteColor : Person -> Person -> Bool
    sameFavoriteColor = fnContraMap2 (.favorites >> .color) (==)

-}
fnContraMap2 : (a -> b) -> (b -> b -> c) -> (a -> a -> c)
fnContraMap2 ab original first second =
    original (ab first) (ab second)


{-| Same as fnContraMap2 but for 3 argument functions.
-}
fnContraMap3 : (a -> b) -> (b -> b -> b -> c) -> (a -> a -> a -> c)
fnContraMap3 ab original first second third =
    original (ab first) (ab second) (ab third)



-- ------------------------------------------------------------------------------
-- Predicate
-- ------------------------------------------------------------------------------


type alias Predicate a =
    a -> Bool


{-| Return a new predicate that is true if both of the two predicates return true.
Note that this is short-circuited, meaning that the second predicate will not be invoked if the first returns false.
-}
both : Predicate a -> Predicate a -> Predicate a
both left right a =
    left a && right a


{-| Takes a list of predicates and returns a predicate that returns true for a given list of arguments if every one of the provided predicates is satisfied by those arguments.

    isAmazing : Person -> Bool
    isAmazing = allPass [isKind, isCreative, isHardWorking, isIntelligent]

-}
allPass : List (Predicate a) -> Predicate a
allPass preds a =
    List.all ((|>) a) preds


{-| Takes a list of predicates and returns a predicate that returns true for a given list of arguments if at least one of the provided predicates is satisfied by those arguments.

    hasAtLeastOneGoodQuality : Person -> Bool
    hasAtLeastOneGoodQuality = anyPass [Person.isKind, Person.isCreative, Person.isHardWorking, Person.isIntelligent]

-}
anyPass : List (Predicate a) -> Predicate a
anyPass preds a =
    List.any ((|>) a) preds


{-| Return a new predicate that is true if either of the two predicates return true.
Note that this is short-circuited, meaning that the second predicate will not be invoked if the first returns true.
-}
either : Predicate a -> Predicate a -> Predicate a
either left right a =
    left a || right a


{-| Invert (negate, complement) a predicate i.e if the predicate would have return True for some `a` it will now return False and vice versa.
-}
complement : Predicate a -> Predicate a
complement fn =
    fn >> not


{-| A predicate that always returns true.
-}
true : Predicate a
true =
    always True


{-| A predicate that always returns false.
-}
false : Predicate a
false =
    always False



-- ------------------------------------------------------------------------------
-- Flow Control
-- ------------------------------------------------------------------------------


{-| Creates a function that will process either the whenTrue or the whenFalse function depending upon the result of the condition predicate.

    ifElse
        (.weightInLbs >> R.Relation.greaterThan 500)
        (.name >> String.append "Sorry. You cannot ride the rollercoaster ")
        (.name >> String.append "Enjoy your ride ")

-}
ifElse : Predicate a -> (a -> b) -> (a -> b) -> (a -> b)
ifElse condition whenTrue whenFalse input =
    if condition input then
        whenTrue input

    else
        whenFalse input


{-| Returns a function which encapsulates if/else, if/else, ... logic given a list of (predicate, transformer) tuples.

  - The condition pairs are processed in order
      - and returns the transformation of the first predicate that passes
  - If no conditions pass then returns Nothing.

-}
cond : List ( Predicate a, a -> b ) -> a -> Maybe b
cond cases input =
    let
        apply =
            (|>) input
    in
    cases
        |> List.Extra.find (Tuple.first >> apply)
        |> Maybe.map (Tuple.second >> apply)


type alias Thunk a =
    () -> a


{-| Same as `cond` but also provides a default option in the case that none of the conditions pass.
-}
condDefault : List ( Predicate a, a -> b ) -> Thunk b -> (a -> b)
condDefault cases defaultThunk a =
    case cond cases a of
        Just v ->
            v

        Nothing ->
            defaultThunk ()


{-| Tests the final argument by passing it to the given predicate function.

  - If the predicate is satisfied, the function will return the result of calling the whenTrueFn function with the same argument.
  - If the predicate is not satisfied, the argument is returned as is.

-}
when : Predicate a -> (a -> a) -> (a -> a)
when condition transform a =
    if condition a then
        transform a

    else
        a


{-| Tests the final argument by passing it to the given predicate function.

  - If the predicate is not satisfied, the function will return the result of calling the whenFalseFn function with the same argument.
  - If the predicate is satisfied, the argument is returned as is.

-}
unless : Predicate a -> (a -> a) -> (a -> a)
unless whenFalse =
    when (complement whenFalse)


{-| Takes a predicate, a transformation function, and an initial value, and returns a value of the same type as the initial value.
It does so by applying the transformation until the predicate is satisfied, at which point it returns the satisfactory value.
-}
until : Predicate a -> (a -> a) -> (a -> a)
until condition transform =
    let
        aux current =
            if condition current then
                current

            else
                aux (transform current)
    in
    aux



-- ------------------------------------------------------------------------------
-- Relation
-- ------------------------------------------------------------------------------


{-| Designed for use in pipelines or currying. Returns a predicate that tests if the value is less than the first value given.

    20 |> lessThan 10 -- False

    20 |> lessThan 30 -- True

-}
lessThan : comparable -> comparable -> Bool
lessThan a b =
    b < a


{-| Designed for currying. Returns a predicate that tests if the value is less than or equal to the first value given.

    20 |> lessThanEqualTo 10 -- False

    20 |> lessThanEqualTo 20 -- True

    [5, 10, 11, 20]
    |> List.map (lessThanEqualto 10) -- [True, True, False, False]

-}
lessThanEqualTo : comparable -> Predicate comparable
lessThanEqualTo a b =
    b <= a


{-| Designed for currying. Returns a predicate that tests if the value is greater than the first value given.

    20 |> greaterThan 10 -- True

    20 |> greaterThan 20 -- False

    [5, 10, 11, 20]
    |> List.map (greaterThan 10) -- [False, False, True, True]

-}
greaterThan : comparable -> Predicate comparable
greaterThan a b =
    b > a


{-| Designed for currying. Returns a predicate that tests if the value is greater than or equal to the first value given.

    20 |> greaterThanEqualTo 10 -- True

    20 |> greaterThanEqualTo 20 -- False

    [5, 10, 11, 20]
    |> List.map (greaterThanEqualTo 10) -- [False, True, True, True]

-}
greaterThanEqualTo : comparable -> Predicate comparable
greaterThanEqualTo a b =
    b >= a


{-| A natural language alias for `==` that also helps to avoid parenthesis when writing point-free flows

    employees
    |> List.filter <| .employmentType >> equals Contractor

-}
equals : a -> Predicate a
equals =
    (==)



-- ------------------------------------------------------------------------------
-- Math
-- ------------------------------------------------------------------------------


{-| A literate alias for addition that is nice for building functional pipelines by avoiding parenthesis.

    List.map <| adding 5

rather than

    List.map <| (+) 5

-}
adding : number -> number -> number
adding a b =
    a + b


{-| Subtraction alias designed for pipelines i.e. the order is swapped such that the subtrahend is the first argument.

    10
    |> subtracting 4 -- 6

    [20, 30, 40]
    |> List.map (subtracting 6) -- [14, 24, 34]

-}
subtracting : number -> number -> number
subtracting subtrahend minuend =
    minuend - subtrahend


{-| A natural language alias for \*.
-}
multiplying : number -> number -> number
multiplying =
    (*)


{-| Division designed for pipelines i.e. the divisor is the first argument.

    20
    |> divideByInt 4 -- 5

    [20, 32, 40]
    |> List (divideByInt 4) -- [5, 8, 10]

-}
dividedByInt : Int -> Int -> Int
dividedByInt divisor dividend =
    dividend // divisor


{-| Division designed for pipelines i.e. the divisor is the first argument.

    20
    |> dividedByFloat 2.5 -- 8.0

    [20, 25, 26.25]
    |> List (divideByFloat 2.5) -- [8.0, 10.0, 10.5]

-}
dividedByFloat : Float -> Float -> Float
dividedByFloat divisor dividend =
    dividend / divisor


{-| Negate the given number.
-}
negated : number -> number
negated =
    (*) -1
