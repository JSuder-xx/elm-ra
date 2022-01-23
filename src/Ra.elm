module Ra exposing
    ( allPass, anyPass, both, either, complement, false, true
    , lessThan, lessThanEqualTo, greaterThan, greaterThanEqualTo, equals
    , adding, subtracting, dividedByInt, dividedByFloat, multiplying, negated
    , ifElse, cond, condDefault, maybeWhen, when, unless, until
    , converge, converge3, convergeList, curry, curry3, flip, fnContraMap, fnContraMap2, fnContraMap3, uncurry, uncurry3
    , isMemberOf
    , deduplicateConsecutiveItemsBy, partitionWhile
    )

{-| Ra supports Pointfree style in Elm by providing various combinators to work with Predicates, Relations, Math, Functions, and Flow Control.

The value of Pointfree is to improve readability and safety. The goal is not to reduce keystrokes or to seem clever!

Generally, readable pointfree style involves trading low signal lambda argument names for high signal top-level function names. Just as the return on investment of unit testing
increases when the code under test relies on abstractions rather than concretions (DI), pointfree return on investment increases when the code is written to declare
normalized (typically small) and meaningfully named top level functions. Remember that the goal is to increase the ratio of semantically rich domain terms to programming language and
computer science-y tokens. Pointfree becomes an indecipherable mess when expressions contain more combinators than they do named domain functions. This is often a sign of anemic types or
functions that do too much such that they cannot be re-composed.


## Less Decoding

The declaration of a lambda with an argument and repetitious application of the argument introduces noise that can obscure the meaning by forcing the reader to decode.

```elm
|> List.filter (\person -> person.isHungy && (Person.canEat meal person))
```

By contrast, the pointfree version is purely declarative, has fewer moving parts, and a less ambiguous interpretation.

```elm
|> List.filter (both .isHungry (Person.canEat meal))
```

A lambda creates an execution context that captures the outer enclosing environment. The result is that the reader must _consider_ the possible
impact of code at an elevated scope which both increases the cognitive load of reading the code and also increases the possibility for certain mistakes.


## Safer

When creating a lambda it is impossible to inadvertently apply values from the outer scope, but this is impossible with pointfree because functions are only composed and not applied or called. Consider the code below
which checks if the passed `person` is hungry and then checks if `personB` can eat the meal (where `personB` has presumably been declared in an outer scope).

```elm
-- Whoops! personB is a typo (possibly from code completion) that type-checks but is not what the author intended
|> List.filter (\person -> person.isHungy && (Person.canEat meal personB))
```

By contrast, the declarative pointfree version provides no opportunity to make such a mistake. The predicate will operate on only a single person.

```elm
|> List.filter (both .isHungry (Person.canEat meal))
```


## Increased Signal

When writing pointfree where it makes sense, it subsequently increases the information communicated to the reader when pointfree is **not** used. For example, when observing a lambda one might reasonably suspect

  - it is required for recursion
  - or there are multiple arguments that must be combined in interesting ways
  - or there is interesting interaction with arguments and let bindings in the outer scope.


## Categories


### Predicate Combinators

Predicate combinators provide a huge readability win when you have named predicates.

@docs allPass, anyPass, both, either, complement, false, true


### Readable Chain and Composition Relations

Partial application of the native relation operators is not intuitive or readable because the order is reversed from what one might expect.
For example, `((>=) 21)` does not return True for numbers that are greater than or equal to 21 but rather returns True for numbers less than
21 because the 21 is applied on the left i.e. `n -> 21 >= n`.

By contrast, the `greaterThanEqualTo` function returns a test of numbers greater than or equal to the first number given. So `greaterThanEqualTo 21`
is `n -> n >= 21`.

@docs lessThan, lessThanEqualTo, greaterThan, greaterThanEqualTo, equals


### Readable Chain and Composition Math

@docs adding, subtracting, dividedByInt, dividedByFloat, multiplying, negated


### Flow Control

@docs ifElse, cond, condDefault, maybeWhen, when, unless, until


### Function Combinators

@docs converge, converge3, convergeList, curry, curry3, flip, fnContraMap, fnContraMap2, fnContraMap3, uncurry, uncurry3


### Dict

@docs isMemberOf


### List

@docs deduplicateConsecutiveItemsBy, partitionWhile

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


{-| Deduplicate consecutive items in a list using a function to extract the element of interest.

    deduplicateConsecutiveItemsBy identity [ 1, 1, 1, 2, 3, 3 ] -- [1, 2, 3]

    deduplicateConsecutiveItemsBy
        Tuple.second
        [ ("Betty", 1), ("Tom", 1), ("Jane", 2)] -- [("Betty", 1), ("Jane", 2)]

-}
deduplicateConsecutiveItemsBy : (a -> b) -> List a -> List a
deduplicateConsecutiveItemsBy key =
    List.Extra.groupWhile (fnContraMap2 key equals)
        >> List.map Tuple.first


{-| Returns all of the items in the list that pass the given predicate up until the first item that fails in the first position
and the remaining items in the second.

    partitionWhile (lessThanEqualTo 10) [1, 5, 10, 15, 10, 3]
    -- ([1, 5, 10], [15, 10, 3])

    partitionWhile (lessThanEqualTo 10) [11, 20, 30, 5, 3]
    -- ([], [11, 20, 30, 5, 3])

    partitionWhile (lessThanEqualTo 10) [1, 5, 10, 7]
    -- ([1, 5, 10, 7], [])

-}
partitionWhile : (a -> Bool) -> List a -> ( List a, List a )
partitionWhile p list =
    list
        |> List.Extra.splitWhen (complement p)
        |> Maybe.withDefault ( list, [] )



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
    isAmazing = allPass [isKind, isCreative, isHardWorking]

-}
allPass : List (Predicate a) -> Predicate a
allPass preds a =
    List.all ((|>) a) preds


{-| Takes a list of predicates and returns a predicate that returns true for a given list of arguments if at least one of the provided predicates is satisfied by those arguments.

    isOkay : Person -> Bool
    isOkay = anyPass [isKind, isCreative, isHardWorking]

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
        (always "Sorry. You cannot ride the coaster.")
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


{-| Tests the final argument against the predicate and if true then performs the transformation.
This is super helpful when combined with List.filterMap. For example, let's say you wanted the names of just the cool people

    allThePeople
    |> List.filterMap (maybeWhen .isCool .fullName)

-}
maybeWhen : Predicate a -> (a -> b) -> a -> Maybe b
maybeWhen condition transform a =
    if condition a then
        a |> transform |> Just

    else
        Nothing


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

    [5, 10, 11, 20] |> List.map (lessThan 10)
    -- [True, False, False, False]

-}
lessThan : comparable -> comparable -> Bool
lessThan a b =
    b < a


{-| Designed for currying. Returns a predicate that tests if the value is less than or equal to the first value given.

    [5, 10, 11, 20] |> List.map (lessThanEqualto 10)
    -- [True, True, False, False]

-}
lessThanEqualTo : comparable -> Predicate comparable
lessThanEqualTo a b =
    b <= a


{-| Designed for currying. Returns a predicate that tests if the value is greater than the first value given.

    [5, 10, 11, 20] |> List.map (greaterThan 10)
    -- [False, False, True, True]

-}
greaterThan : comparable -> Predicate comparable
greaterThan a b =
    b > a


{-| Designed for currying. Returns a predicate that tests if the value is greater than or equal to the first value given.

    [5, 10, 11, 20]
    |> List.map (greaterThanEqualTo 10) -- [False, True, True, True]

-}
greaterThanEqualTo : comparable -> Predicate comparable
greaterThanEqualTo a b =
    b >= a


{-| A natural language alias for `==` that also helps to avoid parenthesis when writing point-free flows

    employees
    |> List.filter (.employmentType >> equals Contractor)

-}
equals : a -> Predicate a
equals =
    (==)



-- ------------------------------------------------------------------------------
-- Math
-- ------------------------------------------------------------------------------


{-| A literate alias for addition that is nice for building functional pipelines by avoiding parenthesis.

    [5, 10, 15, 20] |> List.map (adding 5)
    -- [10, 15, 20, 25]

-}
adding : number -> number -> number
adding a b =
    a + b


{-| Subtraction alias designed for pipelines i.e. the order is swapped such that the subtrahend is the first argument.

    [20, 30, 40]
    |> List.map (subtracting 6)
    -- [14, 24, 34]

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

    [20, 32, 40] |> List (divideByInt 4)
    -- [5, 8, 10]

-}
dividedByInt : Int -> Int -> Int
dividedByInt divisor dividend =
    dividend // divisor


{-| Division designed for pipelines i.e. the divisor is the first argument.

    [20, 25, 26.25] |> List (divideByFloat 2.5)
    -- [8.0, 10.0, 10.5]

-}
dividedByFloat : Float -> Float -> Float
dividedByFloat divisor dividend =
    dividend / divisor


{-| Negate the given number.
-}
negated : number -> number
negated =
    (*) -1
