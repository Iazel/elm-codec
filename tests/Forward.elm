module Forward exposing (suite)

import Base
import Bytes.Decode as JD
import Codec exposing (Codec)
import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Set
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Testing forward and backward compat"
        [ -- describe "Adding a variant" addVariant
          --, describe "Remove parameters" removeParameters
          describe "Any to constant" anyToConstant
        ]


compatible : Fuzzer a -> (a -> b) -> Codec a -> Codec b -> Test
compatible fuzzer map oldCodec newCodec =
    fuzz fuzzer "compatible" <|
        \value ->
            value
                |> Codec.encodeToValue oldCodec
                |> Codec.decodeValue newCodec
                |> Expect.equal (Just <| map value)


forward : Fuzzer old -> (old -> new) -> Codec old -> Codec new -> Test
forward fuzzer map oldCodec newCodec =
    describe "forward"
        [ describe "old"
            [ Base.roundtrips fuzzer oldCodec
            ]
        , describe "new"
            [ Base.roundtrips (Fuzz.map map fuzzer) newCodec
            ]
        , describe "old value with new codec"
            [ compatible fuzzer map oldCodec newCodec
            ]
        ]


both :
    Fuzzer old
    -> (old -> new)
    -> Codec old
    -> Fuzzer new
    -> (new -> old)
    -> Codec new
    -> List Test
both oldFuzzer oldToNew oldCodec newFuzzer newToOld newCodec =
    [ describe "old"
        [ Base.roundtrips oldFuzzer oldCodec
        ]
    , describe "new"
        [ Base.roundtrips newFuzzer newCodec
        ]
    , describe "old value with new codec"
        [ compatible oldFuzzer oldToNew oldCodec newCodec
        ]
    , describe "new value with old codec"
        [ compatible newFuzzer newToOld newCodec oldCodec
        ]
    ]


anyToConstant : List Test
anyToConstant =
    [ forward Fuzz.string (always 3) Codec.string (Codec.constant 3)
    ]


type alias Point2 =
    { x : Int
    , y : Int
    }


point2Fuzzer =
    Fuzz.map2 Point2 Fuzz.int Fuzz.int


point2Codec =
    Codec.object Point2
        |> Codec.field .x Codec.int
        |> Codec.field .y Codec.int
        |> Codec.buildObject



--type alias Point2_5 =
--    { x : Int
--    , y : Int
--    , z : Maybe Int
--    }
--
--
--point2_5Fuzzer =
--    Fuzz.map3 Point2_5 Fuzz.int Fuzz.int (Fuzz.maybe Fuzz.int)
--
--
--point2_5Codec =
--    Codec.object Point2_5
--        |> Codec.field .x Codec.int
--        |> Codec.field .y Codec.int
--        |> Codec.optionalField "z" .z Codec.int
--        |> Codec.buildObject
--
--
--addOptionalField : List Test
--addOptionalField =
--    both
--        point2Fuzzer
--        (\{ x, y } -> { x = x, y = y, z = Nothing })
--        point2Codec
--        point2_5Fuzzer
--        (\{ x, y } -> { x = x, y = y })
--        point2_5Codec
