port module Commands exposing (Msg(..), getFeed, getFeedSub, getThxUpdateCmd, updateThxSub)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, partialThxDecoder, thxDecoder)
import Time exposing (every)


type Msg
    = Load
    | TokenChanged String
    | ListLoaded (Result Error (List Thx))
    | ThxUpdated (Result Decode.Error ThxPartial)


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


getFeedSub : String -> Sub Msg
getFeedSub token =
    every 7000 (\_ -> Load)


port getThxUpdate : ThxPartialRaw -> Cmd msg


getThxUpdateCmd : Thx -> Cmd Msg
getThxUpdateCmd t =
    getThxUpdate (ThxPartialRaw t.id t.createdAt t.text)


port updateThx : (Decode.Value -> msg) -> Sub msg


updateThxSub : Sub Msg
updateThxSub =
    updateThx (\v -> v |> decodeValue partialThxDecoder |> ThxUpdated)
