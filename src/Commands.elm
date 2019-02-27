port module Commands exposing (ApiState(..), Msg(..), getFeed, getFeedSub, getThxUpdateCmd, setToken, toApiState, updateThxSub)

import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, int, list, string)
import Json.Decode.Pipeline exposing (custom, required)
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, partialThxDecoder, thxDecoder)
import Time exposing (every)


type Msg
    = Load
    | TokenChanged String
    | Login
    | ListLoaded (Result Error (List Thx))
    | ThxUpdated (Result Decode.Error ThxPartial)


getFeed : String -> String -> Cmd Msg
getFeed apiUrl token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = apiUrl ++ "/thanks/list"
        , body = Http.emptyBody
        , expect = Http.expectJson (list thxDecoder)
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send ListLoaded


getFeedSub : String -> Sub Msg
getFeedSub token =
    every 30000 (\_ -> Load)


port getThxUpdate : ThxPartialRaw -> Cmd msg


getThxUpdateCmd : Thx -> Cmd Msg
getThxUpdateCmd t =
    getThxUpdate (ThxPartialRaw t.id t.createdAt t.text)


port updateThx : (Decode.Value -> msg) -> Sub msg


updateThxSub : Sub Msg
updateThxSub =
    updateThx (\v -> decodeValue partialThxDecoder v |> ThxUpdated)


type ApiState
    = Empty
    | TokenNotChecked
    | InvalidToken
    | NoResponse


toApiState : Error -> ApiState
toApiState err =
    case err of
        BadStatus _ ->
            InvalidToken

        _ ->
            NoResponse


port setToken : String -> Cmd msg
