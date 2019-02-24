port module Commands exposing (Msg(..), getFeed, getThxUpdateCmd, subscriptions)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, partialThxDecoder, thxDecoder)


type Msg
    = Load
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


port getThxUpdate : ThxPartialRaw -> Cmd msg


getThxUpdateCmd : Thx -> Cmd Msg
getThxUpdateCmd t =
    getThxUpdate (ThxPartialRaw t.id t.createdAt t.text)


port updateThx : (Decode.Value -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    Sub.batch [ updateThx (\v -> v |> decodeValue partialThxDecoder |> ThxUpdated) ]
