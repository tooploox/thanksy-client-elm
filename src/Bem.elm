module Bem exposing (bind)

import Html exposing (Attribute)
import Html.Attributes exposing (class)
import List exposing (map)
import String exposing (join)


applyModifier : String -> String -> String
applyModifier base modifier =
    join "--" [ base, modifier ]


className : String -> List String -> String
className base modifiers =
    let
        apply =
            applyModifier base
    in
    modifiers
        |> map apply
        |> (::) base
        |> join " "


bind : String -> ( List String -> Attribute msg, String -> List String -> Attribute msg )
bind bName =
    let
        bClass modifiers =
            className bName modifiers
                |> class

        eClass eName modifiers =
            className (join "__" [ bName, eName ]) modifiers
                |> class
    in
    ( bClass
    , eClass
    )
