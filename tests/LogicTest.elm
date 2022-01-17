module LogicTest exposing (..)

import Expect
import Ra
import Test exposing (..)


suite : Test
suite =
    describe "Flow Control"
        [ describe "ifElse" <|
            let
                rideMessage =
                    Ra.ifElse
                        (.weightInLbs >> Ra.greaterThan 500)
                        (.name >> String.append "Sorry. You cannot ride the rollercoaster ")
                        (.name >> String.append "Enjoy your ride ")
            in
            [ test "true branch" <|
                always <|
                    Expect.equal "Sorry. You cannot ride the rollercoaster Albert" (rideMessage { weightInLbs = 501, name = "Albert" })
            , test "false branch" <|
                always <|
                    Expect.equal "Enjoy your ride Bob" (rideMessage { weightInLbs = 250, name = "Bob" })
            ]
        , describe "cond" <|
            let
                singleCondition =
                    Ra.cond [ ( Ra.greaterThan 10, Ra.adding 5 ) ]

                threeConditions =
                    Ra.cond
                        [ ( Ra.greaterThan 20, Ra.adding 4 )
                        , ( Ra.greaterThan 10, Ra.adding 5 )
                        , ( Ra.greaterThanEqualTo 0, identity )
                        ]
            in
            [ test "empty condition list always returns Nothing" <|
                always <|
                    Expect.equal (Ra.cond [] 1) Nothing
            , test "single condition not met" <| always <| Expect.equal (singleCondition 5) Nothing
            , test "single condition met" <| always <| Expect.equal (singleCondition 11) (Just 16)
            , test "three conditions first met" <| always <| Expect.equal (threeConditions 21) (Just 25)
            , test "three conditions second met" <| always <| Expect.equal (threeConditions 11) (Just 16)
            , test "three conditions third met" <| always <| Expect.equal (threeConditions 0) (Just 0)
            , test "three conditions none met" <| always <| Expect.equal (threeConditions -1) Nothing
            ]
        ]
