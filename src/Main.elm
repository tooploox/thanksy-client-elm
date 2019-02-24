port module Main exposing (main)

import Browser
import Commands exposing (Msg(..), getFeed, parse, subscriptions)
import Components exposing (thxList)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Value)
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, User, updateThxList)


type alias Model =
    { thxList : List Thx
    , token : String
    , error : Maybe Http.Error
    }


type alias Flags =
    { token : String }


initialModel : Model
initialModel =
    { thxList = []
    , token = ""
    , error = Nothing
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { initialModel | token = flags.token }, getFeed flags.token )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


getError : Maybe Http.Error -> String
getError err =
    case err of
        Nothing ->
            ""

        Just error ->
            "Error: " ++ Debug.toString error


viewThxList : Model -> Html Msg
viewThxList model =
    div [] [ thxList model.thxList, text (getError model.error) ]


view : Model -> Browser.Document Msg
view model =
    { body = [ viewThxList model ]
    , title = "Thanksy - We want people to be appreciated"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getFeed model.token )

        ListLoaded (Ok thxList) ->
            ( { model | thxList = thxList }, Cmd.batch (List.map parse thxList) )

        ListLoaded (Err err) ->
            ( { model | thxList = [], error = Just err }, Cmd.none )

        ThxParsed (Ok thxPartial) ->
            ( { model | thxList = updateThxList thxPartial model.thxList }, Cmd.none )

        _ ->
            ( model, Cmd.none )
