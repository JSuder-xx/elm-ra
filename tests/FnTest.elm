module FnTest exposing (..)

import Dict
import Expect
import Ra
import Test exposing (..)


suite : Test
suite =
    describe "Function"
        [ describe "contraMap2" <|
            let
                equallyCool =
                    Ra.fnContraMap2 .isCool (==)
            in
            [ test "when both arguments project to same" <|
                always <|
                    Expect.equal (equallyCool { isCool = True } { isCool = True }) True
            , test "when different" <|
                always <|
                    Expect.equal (equallyCool { isCool = False } { isCool = True }) False
            ]
        , describe "converge" <|
            let
                insert =
                    Ra.converge Dict.insert ( identity, String.length )
            in
            [ test "smoke" <|
                always <|
                    Expect.equal
                        (insert "key" Dict.empty)
                        (Dict.fromList [ ( "key", 3 ) ])
            ]
        ]
