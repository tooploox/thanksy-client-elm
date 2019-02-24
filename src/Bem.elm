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
        className =
            \m -> join "--" [ block, m ]
    in
    block ++ " " ++ (List.map className modifiers |> join " ") |> String.trim


element : String -> Element msg
element name =
    \p -> div [ name ++ "__" ++ p |> class ]


mbind : List String -> String -> ( Block msg, Element msg, ElementText msg )
mbind modifiers name =
    ( div [ class (blockClass modifiers name) ]
    , element name
    , \p -> \txt -> element name p [ text txt ]
    )


bind =
    mbind []
