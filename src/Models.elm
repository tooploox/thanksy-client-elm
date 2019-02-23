module Models exposing (Msg(..), Position, TextChunk(..), Thx, User, getFeed)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
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
        |> required "real_name" string
        |> required "avatar_url" string
        |> required "name" string
        |> required "id" string


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
        |> required "receivers" (list userDecoder)
        |> required "giver" userDecoder
        |> required "id" int
        |> required "created_at" string
        |> required "love_count" int
        |> required "confetti_count" int
        |> required "clap_count" int
        |> required "wow_count" int
        |> custom chunksDecoder


type alias Position =
    { x : Int, y : Int }



-- positionDecoder : Decoder Position
-- positionDecoder =
--     Decode.succeed Position
--         |> required "clientX" int
--         |> required "clientY" int
-- mouseMoveToMsg : Value -> Msg
-- mouseMoveToMsg v =
--     decodeValue positionDecoder v |> MouseMoved


type Msg
    = Load
    | UpdatePositon Position
    | ListLoaded (Result Error (List Thx))
    | MouseMoved (Result Decode.Error Position)


api =
    --"https://thanksy.herokuapp.com"
    "http://localhost:3000"


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
