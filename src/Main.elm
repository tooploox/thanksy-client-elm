port module Main exposing (main)

import Browser
import Components exposing (thxList)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Value)
import Models exposing (Msg(..), Position, TextChunk(..), Thx, User, getFeed)


type alias Model =
    { thxList : List Thx
    , token : String
    , error : Maybe Http.Error
    , pos : Position
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
            , pos = Position 0 0
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
                        "Error: "
                 -- ++ Debug.toString error
                )
    in
    { body =
        [ div [] [ thxList model.thxList, err, text (String.fromInt model.pos.x ++ "," ++ String.fromInt model.pos.y) ]
        ]
    , title = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseMoved (Result.Ok v) ->
            ( { model | pos = v }, Cmd.none )

        MouseMoved (Result.Err _) ->
            ( model, Cmd.none )

        Load ->
            ( model, getFeed model.token )

        UpdatePositon v ->
            ( { model | pos = v }, Cmd.none )

        ListLoaded (Ok thxList) ->
            ( { model | thxList = thxList }, Cmd.none )

        ListLoaded (Err err) ->
            ( { model | thxList = [], error = Just err }, Cmd.none )


port onMouseMove : (Position -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    onMouseMove UpdatePositon
