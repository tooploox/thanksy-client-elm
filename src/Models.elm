port module Models exposing (Msg(..), Position, TextChunk(..), Thx, ThxPartial, ThxPartialRaw, User, getFeed, parse, thxPartialSub, updateThxList)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)


type Msg
    = Load
    | UpdatePositon Position
    | ListLoaded (Result Error (List Thx))
    | ThxParsed (Result Decode.Error ThxPartial)


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


type alias ThxPartialRaw =
    { id : Int
    , createdAt : String
    , body : String
    }


type alias ThxPartial =
    { id : Int
    , createdAt : String
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


port parseText : ThxPartialRaw -> Cmd msg


parse : Thx -> Cmd msg
parse t =
    let
        body =
            case List.head t.chunks of
                Just (Text a) ->
                    a

                _ ->
                    ""
    in
    parseText (ThxPartialRaw t.id t.createdAt body)


type alias Position =
    { x : Int, y : Int }


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


textChunkDecoder : String -> Decoder TextChunk
textChunkDecoder t =
    case t of
        "text" ->
            Decode.map Text (field "caption" string)

        "nickname" ->
            Decode.map Nickname (field "caption" string)

        "emoji" ->
            Decode.map2 Emoji (field "url" string) (field "caption" string)

        _ ->
            Decode.fail ("Got invalid type: " ++ t)


textChunksDecoder : Decoder (List TextChunk)
textChunksDecoder =
    list <| (field "type" string |> Decode.andThen textChunkDecoder)


partialThxDecoder : Decoder ThxPartial
partialThxDecoder =
    Decode.succeed ThxPartial
        |> required "id" int
        |> required "createdAt" string
        |> required "chunks" textChunksDecoder


toThxParsed : Value -> Msg
toThxParsed v =
    v |> decodeValue partialThxDecoder |> ThxParsed


port getThxPartial : (Decode.Value -> msg) -> Sub msg


thxPartialSub : Sub Msg
thxPartialSub =
    getThxPartial toThxParsed


updateThx : ThxPartial -> Thx -> Thx
updateThx partial item =
    if item.id == partial.id then
        { item | chunks = partial.chunks, createdAt = partial.createdAt }

    else
        item


updateThxList : ThxPartial -> List Thx -> List Thx
updateThxList partial thxList =
    thxList |> List.map (updateThx partial)
