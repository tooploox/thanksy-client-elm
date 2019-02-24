port module Commands exposing (Msg(..), getFeed, getThxPartial, parse, parseText, subscriptions, toThxParsed)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, partialThxDecoder, thxDecoder)


type Msg
    = Load
    | ListLoaded (Result Error (List Thx))
    | ThxParsed (Result Decode.Error ThxPartial)


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


port parseText : ThxPartialRaw -> Cmd msg


parse : Thx -> Cmd Msg
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


toThxParsed : Value -> Msg
toThxParsed v =
    v |> decodeValue partialThxDecoder |> ThxParsed


port getThxPartial : (Decode.Value -> msg) -> Sub msg


thxPartialSub : Sub Msg
thxPartialSub =
    getThxPartial toThxParsed


subscriptions : model -> Sub Msg
subscriptions _ =
    Sub.batch [ thxPartialSub ]
