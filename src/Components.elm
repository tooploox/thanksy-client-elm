module Components exposing (thxList)

import Bem exposing (bind, mbind)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import List exposing (..)
import Models exposing (Msg, TextChunk(..), Thx, User, getFeed)
import String exposing (join, toLower)


thxList : List Thx -> Html msg
thxList ts =
    let
        ( block, element, elementTxt ) =
            bind "ThxList"
    in
    block
        [ h1 [] [ text "Recent thanks" ]
        , element "Container" (List.map thx ts)
        ]


thx : Thx -> Html msg
thx t =
    let
        ( block, element, elementTxt ) =
            bind "Thx"
    in
    div [ class "Thx", Attr.id ("thx" ++ String.fromInt t.id) ]
        [ userHeader t.giver t.createdAt
        , element "Content"
            [ textChunks t.chunks
            , avatars t.receivers 5
            , reactions t
            ]
        ]


userHeader : User -> String -> Html msg
userHeader u createdAt =
    let
        ( block, element, elementTxt ) =
            bind "UserHeader"
    in
    block
        [ element "Avatar"
            [ img [ Attr.src u.avatarUrl ] [] ]
        , element "Details"
            [ elementTxt "Name" u.realName
            , elementTxt "Time" createdAt
            ]
        ]


reaction : String -> Int -> Html msg
reaction kind count =
    let
        ( block, element, elementTxt ) =
            mbind [ kind ] "Reaction"
    in
    block
        [ element "Icon" []
        , elementTxt "Count" (String.fromInt count)
        ]


reactions : Thx -> Html msg
reactions t =
    div [ class "Reactions" ]
        [ reaction "love" t.loveCount
        , reaction "confetti" t.confettiCount
        , reaction "clap" t.clapCount
        , reaction "wow" t.wowCount
        ]


avatar : User -> Html msg
avatar u =
    div [ class "Avatar", Attr.style "background-image" ("url(" ++ u.avatarUrl ++ ")") ] []


avatars : List User -> Int -> Html msg
avatars us max =
    let
        ( block, element, _ ) =
            bind "Avatars"

        elements =
            take max us
                |> reverse
                |> List.map avatar
    in
    block
        [ element "Container" elements ]


textChunk : TextChunk -> Html msg
textChunk t =
    case t of
        Text caption ->
            span [] [ text caption ]

        Nickname caption ->
            mark [] [ text caption ]

        Emoji url caption ->
            img [ Attr.src url, Attr.alt caption ] []


textChunks : List TextChunk -> Html msg
textChunks chunks =
    div [ class "TextChunks" ] (List.map textChunk chunks)
