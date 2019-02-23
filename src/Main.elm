port module Main exposing (main)

import Browser
import Components exposing (thxList)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Value)
import Models exposing (Msg(..), Position, TextChunk(..), Thx, ThxPartial, ThxPartialRaw, User, getFeed, parse, thxPartialSub, updateThxList)


type alias Model =
    { thxList : List Thx
    , token : String
    , error : Maybe Http.Error
    }


type alias Flags =
    { token : String }


main : Program Flags Model Msg
main =
    let
        initialModel : Model
        initialModel =
            { thxList = []
            , token = ""
            , error = Nothing
            }

        init : Flags -> ( Model, Cmd Msg )
        init flags =
            ( { initialModel | token = flags.token }, getFeed flags.token )
    in
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


view : Model -> Browser.Document Msg
view model =
    let
        err : Html err
        err =
            text
                (case model.error of
                    Nothing ->
                        ""

                    Just error ->
                        "Error: " ++ Debug.toString error
                )

        body =
            [ div [] [ thxList model.thxList, err ] ]
    in
    { body = body
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


port onMouseMove : (Position -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    Sub.batch [ thxPartialSub ]
