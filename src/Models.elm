port module Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, User, filterRecentThxList, filterThxList, partialThxDecoder, thxDecoder, updateThxList)

import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)


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
    , text : String
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
        |> required "text" string
        |> hardcoded []


updateThx : ThxPartial -> Thx -> Thx
updateThx p item =
    if item.id == p.id then
        { item | chunks = p.chunks, createdAt = p.createdAt }

    else
        item


updateThxList : ThxPartial -> List Thx -> List Thx
updateThxList partial thxList =
    thxList |> List.map (updateThx partial)


thxComparison : Thx -> Thx -> Order
thxComparison a b =
    if a.id >= b.id then
        LT

    else if a.id == b.id then
        EQ

    else
        GT


filterThxList : Maybe Int -> List Thx -> List Thx
filterThxList lastThxId ts =
    List.sortWith thxComparison <|
        case lastThxId of
            Nothing ->
                ts

            Just id ->
                List.filter (\v -> v.id <= id) ts


filterRecentThxList : Maybe Int -> List Thx -> List Thx
filterRecentThxList lastThxId ts =
    List.sortWith thxComparison <|
        case lastThxId of
            Nothing ->
                []

            Just id ->
                List.filter (\v -> v.id > id) ts
