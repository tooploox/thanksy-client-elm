module Models exposing (Msg(..), Position, TextChunk(..), Thx, User, getFeed, wheelValueToMsg)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)


type alias User =
    { realName : String
    , avatarUrl : String
    , name : String
    , id : String
    }


type TextChunk
    = Text String
    | Nickname String
    | Emoji String String


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "real_name" Decode.string
        |> required "avatar_url" Decode.string
        |> required "name" Decode.string
        |> required "id" Decode.string


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


chunksDecoder : Decoder (List TextChunk)
chunksDecoder =
    field "text" string |> Decode.map (\v -> [ Text v ])


thxDecoder : Decoder Thx
thxDecoder =
    Decode.succeed Thx
        |> required "receivers" (Decode.list userDecoder)
        |> required "giver" userDecoder
        |> required "id" Decode.int
        |> required "created_at" Decode.string
        |> required "love_count" Decode.int
        |> required "confetti_count" Decode.int
        |> required "clap_count" Decode.int
        |> required "wow_count" Decode.int
        |> custom chunksDecoder


type alias Position =
    { x : Int, y : Int }


wheelDecoder : Decoder Position
wheelDecoder =
    Decode.map2 Position
        (Decode.field "clientX" int)
        (Decode.field "clientY" int)


wheelValueToMsg =
    \val ->
        case decodeValue wheelDecoder val of
            Ok v ->
                Wheel v

            Err _ ->
                NoOp


type Msg
    = Load
    | ListLoaded (Result Error (List Thx))
    | Wheel Position
    | NoOp


api =
    "https://thanksy.herokuapp.com"



-- "http://localhost:3000"


getFeed : String -> Cmd Msg
getFeed token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = api ++ "/thanks/list"
        , body = Http.emptyBody
        , expect = Http.expectJson (list thxDecoder)
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send ListLoaded
