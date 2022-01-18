module RelationTest exposing (..)

import Ra
import Test exposing (..)
import TestHelpers exposing (testTransform)


suite : Test
suite =
    describe "Relation"
        [ testTransform "lessThan"
            { transform = Ra.lessThan 10
            , given = [ 5, 10, 15, 20 ]
            , thenExpect = [ True, False, False, False ]
            }
        , testTransform "lessThanEqualTo"
            { transform = Ra.lessThanEqualTo 10
            , given = [ 5, 10, 15, 20 ]
            , thenExpect = [ True, True, False, False ]
            }
        , testTransform "greaterThan"
            { transform = Ra.greaterThan 10
            , given = [ 5, 10, 15, 20 ]
            , thenExpect = [ False, False, True, True ]
            }
        , testTransform "greaterThanEqualTo"
            { transform = Ra.greaterThanEqualTo 10
            , given = [ 5, 10, 15, 20 ]
            , thenExpect = [ False, True, True, True ]
            }
        , testTransform "equals"
            { transform = Ra.equals 10
            , given = [ 5, 10, 15 ]
            , thenExpect = [ False, True, False ]
            }
        ]
