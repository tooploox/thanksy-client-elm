module MainProd exposing (main)

import Browser
import Commands exposing (Msg)
import Main exposing (Flags, Model, config)


main : Program Flags Model Msg
main =
    Browser.document config
