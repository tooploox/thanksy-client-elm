module Components exposing (error, login, newThx, thxList)

import Bem exposing (bind, mbind, mblock)
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
        ( block, element, elementTxt ) =
            bind "Login"
    in
    block
        [ element "ContentLimiter"
            [ element "Logo" []
            , elementTxt "Mission" "Improving your company's culture"
            , input [ placeholder "Security code", value token, onInput TokenChanged ] []
            , elementTxt "Error" err
            , p [] [ text "Ask a person who has deployed Thanksy on the server about the security code" ]
            , button [ onClick Login ] [ text "Login" ]
            ]
        , element "Blur" []
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

        ( block, element, elementTxt ) =
            mbind modifiers "NewThx"
    in
    block
        [ element "Overlay"
            (case List.head ts of
                Nothing ->
                    []

                Just t ->
                    [ element "ContentLimiter"
                        [ h2 [] [ text (firstWord t.giver.realName ++ " just sent a new Thanks!") ]
                        , textChunks t.chunks True
                        , element "Avatars" [ avatars t.receivers 11 ]
                        , element "ConfettiContainer" []
                        ]
                    ]
            )
        ]


thxList : List Thx -> Html msg
thxList ts =
    let
        ( block, element, elementTxt ) =
            bind "ThxList"
    in
    block
        (if List.isEmpty ts then
            [ element "EmptyContainer"
                [ element "Empty" []
                , elementTxt "Title" "No thanks so far"
                , elementTxt "Subtitle" "Be the first one, use Slack, speak up!"
                ]
            ]

         else
            [ h1 [] [ text "Recent thanks" ]
            , element "Container" (List.map thx ts)
            ]
        )


thx : Thx -> Html msg
thx t =
    let
        ( block, element, elementTxt ) =
            bind "Thx"
    in
    div [ class "Thx", Attr.id ("thx" ++ String.fromInt t.id) ]
        [ userHeader t.giver t.createdAt
        , element "Content"
            [ textChunks t.chunks False
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


textChunks : List TextChunk -> Bool -> Html msg
textChunks chunks light =
    let
        modifiers =
            if light then
                [ "light", "centred" ]

            else
                []
    in
    mblock modifiers "TextChunks" (List.map textChunk chunks)


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
