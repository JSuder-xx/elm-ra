module MathTest exposing (..)

import Ra
import Test exposing (..)
import TestHelpers exposing (testTransform)


suite : Test
suite =
    describe "Math"
        [ testTransform "subtracting"
            { transform = Ra.subtracting 4
            , given = [ 5, 10, 15 ]
            , thenExpect = [ 1, 6, 11 ]
            }
        , testTransform "dividedByFloat"
            { transform = Ra.dividedByFloat 2.5
            , given = [ 5, 6.25, 20 ]
            , thenExpect = [ 2, 2.5, 8 ]
            }
        , testTransform "dividedByInt"
            { transform = Ra.dividedByInt 4
            , given = [ 3, 4, 12, 20 ]
            , thenExpect = [ 0, 1, 3, 5 ]
            }
        , testTransform "negated"
            { transform = Ra.negated
            , given = [ 3, -4, 10, 20, -13 ]
            , thenExpect = [ -3, 4, -10, -20, 13 ]
            }
        ]
