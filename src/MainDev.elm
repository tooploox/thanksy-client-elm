module MainDev exposing (main)

import Commands exposing (Msg)
import Main exposing (Flags, Model, config)
import Monitor


main : Program Flags Model Msg
main =
    Monitor.document config
