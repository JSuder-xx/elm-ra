module TestHelpers exposing (..)

import Expect
import Test exposing (..)


testTransform : String -> { transform : a -> b, given : List a, thenExpect : List b } -> Test
testTransform name { transform, given, thenExpect } =
    test name <| always <| Expect.equal thenExpect (given |> List.map transform)
