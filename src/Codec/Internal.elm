module Codec.Internal exposing (Codec(..), build)

import Bytes.Decode exposing (Decoder)
import Bytes.Encode exposing (Encoder)


{-| A value that knows how to encode and decode a sequence of bytes.
-}
type Codec a
    = Codec
        { encoder : a -> Encoder
        , decoder : Decoder a
        }


{-| If necessary you can create your own `Codec` directly.
This should be a measure of last resort though! If you need to encode and decode records and custom types, use `object` and `custom` respectively.
-}
build : (a -> Encoder) -> Decoder a -> Codec a
build encoder_ decoder_ =
    Codec
        { encoder = encoder_
        , decoder = decoder_
        }
