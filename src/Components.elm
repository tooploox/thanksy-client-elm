module Components exposing (error, login, newThx, thxList)

import Bem exposing (..)
import Commands exposing (Msg(..), getFeed)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import List exposing (..)
import Models exposing (TextChunk(..), Thx, User)
import String exposing (join, toLower)
import String.Extra exposing (softBreak)


login : String -> String -> Html Msg
login token err =
    let
        ( iBlock, isElement ) =
            bind "Login"
    in
    div [ iBlock [] ]
        [ div [ isElement "ContentLimiter" [] ]
            [ div [ isElement "Logo" [] ] []
            , div [ isElement "Mission" [] ] [ text "Improving your company's culture" ]
            , input [ placeholder "Security code", value token, onInput TokenChanged ] []
            , div [ isElement "Error" [] ] [ text err ]
            , p [] [ text "Ask a person who has deployed Thanksy on the server about the security code" ]
            , button [ onClick Login ] [ text "Login" ]
            ]
        , div [ isElement "Blur" [] ] []
        ]


newThx : List Thx -> Html msg
newThx ts =
    let
        modifiers =
            case List.head ts of
                Nothing ->
                    [ "hidden" ]

                _ ->
                    [ "visible" ]

        ( isBlock, isElement ) =
            bind "NewThx"
    in
    div [ isBlock modifiers ]
        [ div [ isElement "Overlay" [] ]
            (case List.head ts of
                Nothing ->
                    []

                Just t ->
                    [ div [ isElement "ContentLimiter" [] ]
                        [ h2 [] [ text (firstWord t.giver.realName ++ " just sent a new Thanks!") ]
                        , textChunks t.chunks True
                        , div [ isElement "Avatars" [] ] [ avatars t.receivers 11 ]
                        , div [ isElement "ConfettiContainer" [] ] []
                        ]
                    ]
            )
        ]


thxList : List Thx -> Html msg
thxList ts =
    let
        ( isBlock, isElement ) =
            bind "ThxList"
    in
    div [ isBlock [] ]
        (if List.isEmpty ts then
            [ div [ isElement "EmptyContainer" [] ]
                [ div [ isElement "Empty" [] ] []
                , div [ isElement "Title" [] ] [ text "No thanks so far" ]
                , div [ isElement "Subtitle" [] ] [ text "Be the first one, use Slack, speak up!" ]
                ]
            ]

         else
            [ h1 [] [ text "Recent thanks" ]
            , div [ isElement "Container" [] ] (List.map thx ts)
            ]
        )


thx : Thx -> Html msg
thx t =
    let
        ( isBlock, isElement ) =
            bind "Thx"
    in
    div
        [ isBlock []
        , Attr.id <| "thx" ++ String.fromInt t.id
        ]
        [ userHeader t.giver t.createdAt
        , div [ isElement "Content" [] ]
            [ textChunks t.chunks False
            , avatars t.receivers 5
            , reactions t
            ]
        ]


userHeader : User -> String -> Html msg
userHeader u createdAt =
    let
        ( isBlock, isElement ) =
            bind "UserHeader"
    in
    div [ isBlock [] ]
        [ div [ isElement "Avatar" [] ]
            [ img [ Attr.src u.avatarUrl ] [] ]
        , div [ isElement "Details" [] ]
            [ div [ isElement "Name" [] ] [ text u.realName ]
            , div [ isElement "Time" [] ] [ text createdAt ]
            ]
        ]


reaction : String -> Int -> Html msg
reaction kind count =
    let
        ( isBlock, isElement ) =
            bind "Reaction"
    in
    div [ isBlock [ kind ] ]
        [ div [ isElement "Icon" [] ] []
        , div [ isElement "Count" [] ] [ text <| String.fromInt count ]
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
        ( isBlock, isElement ) =
            bind "Avatars"

        elements =
            take max us
                |> reverse
                |> List.map avatar
    in
    div [ isBlock [] ]
        [ div [ isElement "Container" [] ] elements ]


textChunk : TextChunk -> Html msg
textChunk t =
    case t of
        Text caption ->
            span [] [ text caption ]

        Nickname caption ->
            mark [] [ text caption ]

        Emoji url caption ->
            img [ Attr.src url, Attr.alt caption ] []


textChunks : List TextChunk -> Bool -> Html msg
textChunks chunks light =
    let
        modifiers =
            if light then
                [ "light", "centred" ]

            else
                []

        ( isBlock, _ ) =
            bind "TextChunks"
    in
    div [ isBlock modifiers ] <| List.map textChunk chunks


error : Maybe Http.Error -> String
error me =
    case me of
        Nothing ->
            ""

        Just e ->
            "Error: " ++ Debug.toString e


firstWord : String -> String
firstWord s =
    let
        arr =
            softBreak 2 s
    in
    case List.head arr of
        Just v ->
            v

        _ ->
            ""
