module Forward exposing (suite)

import Base
import Bytes.Decode as JD
import Codec.Bytes as Codec exposing (Codec)
import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Set
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Testing forward and backward compatability"
        [ describe "Any to constant" anyToConstant
        ]


compatible : String -> Fuzzer a -> (a -> b) -> Codec a -> Codec b -> Test
compatible name fuzzer map oldCodec newCodec =
    fuzz fuzzer name <|
        \value ->
            value
                |> Codec.encodeToValue oldCodec
                |> Codec.decodeValue newCodec
                |> Expect.equal (Just <| map value)


forward : Fuzzer old -> (old -> new) -> Codec old -> Codec new -> Test
forward fuzzer map oldCodec newCodec =
    describe "forward"
        [ Base.roundtrips "old" fuzzer oldCodec
        , Base.roundtrips "new" (Fuzz.map map fuzzer) newCodec
        , compatible "old value with new codec" fuzzer map oldCodec newCodec
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
    [ Base.roundtrips "old" oldFuzzer oldCodec
    , Base.roundtrips "new" newFuzzer newCodec
    , compatible "old value with new codec" oldFuzzer oldToNew oldCodec newCodec
    , compatible "new value with old codec" newFuzzer newToOld newCodec oldCodec
    ]


anyToConstant : List Test
anyToConstant =
    [ forward Fuzz.string (always 3) Codec.string (Codec.constant 3)
    ]
