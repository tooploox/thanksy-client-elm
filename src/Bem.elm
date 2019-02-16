module Bem exposing (bind, mbind)

import Basics
import Html exposing (..)
import Html.Attributes exposing (..)
import String exposing (join, toLower)


type alias Block msg =
    List (Html msg) -> Html msg


type alias Element msg =
    String -> List (Html msg) -> Html msg


type alias ElementText msg =
    String -> String -> Html msg


blockClass : List String -> String -> String
blockClass modifiers block =
    let
        toClass =
            \m -> join "--" [ block, m ]
    in
    block ++ " " ++ (List.map toClass modifiers |> join " ") |> String.trim


mbind : List String -> String -> ( Block msg, Element msg, ElementText msg )
mbind modifiers name =
    let
        block =
            div [ class (blockClass modifiers name) ]

        element =
            \p -> div [ name ++ "__" ++ p |> class ]
    in
    ( block, element, \p -> \txt -> element p [ text txt ] )


bind =
    mbind []
