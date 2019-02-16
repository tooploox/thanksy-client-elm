module Main exposing (main)

import Basics
import Bem exposing (bind, mbind)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import List exposing (..)
import String exposing (join, toLower)


thxFixture : Thx
thxFixture =
    { id = 0
    , receivers =
        [ User "Evan.Czaplicki" "https://avatars3.githubusercontent.com/u/1658058?s=460&v=4"
        , User "Richard Feldman" "https://avatars1.githubusercontent.com/u/1094080?s=460&v=4"
        ]
    , giver = User "Grzegorz Moskal" "https://avatars2.githubusercontent.com/u/1741736?s=88&v=4"
    , createdAt = "Today 10:08 AM"
    , loveCount = 0
    , confettiCount = 1
    , clapCount = 2
    , wowCount = 3
    , chunks =
        [ Text "Thanks for Elm "
        , Nickname "@Evan.Czaplicki"
        , Text " "
        , Nickname "@Richard.Feldman"
        , Text " "
        , Emoji "https://twemoji.maxcdn.com/2/72x72/1f4fa.png" "📺"
        ]
    }


thxListFixture =
    let
        delta =
            \i -> \f -> { f | createdAt = "Today - " ++ String.fromInt i, id = i }
    in
    repeat 10 thxFixture |> List.indexedMap delta


type alias Thx =
    { receivers : List User
    , giver : User
    , id : Int
    , createdAt : String
    , loveCount : Int
    , confettiCount : Int
    , clapCount : Int
    , wowCount : Int
    , chunks : List TextChunk
    }


type alias User =
    { realName : String
    , avatarUrl : String
    }


type TextChunk
    = Text String
    | Nickname String
    | Emoji String String


main =
    thxList thxListFixture


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
    let
        bgImg =
            "url(" ++ u.avatarUrl ++ ")"
    in
    div [ class "Avatar", Attr.style "background-image" bgImg ] []


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
