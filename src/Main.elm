port module Main exposing (main)

import Browser
import Components exposing (thxList)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Value)
import Models exposing (Msg(..), Position, TextChunk(..), Thx, User, getFeed, mouseMoveToMsg)


type alias Model =
    { thxList : List Thx
    , token : String
    , error : Maybe Http.Error
    , pos : Position
    }


main : Program () Model Msg
main =
    let
        initialModel : Model
        initialModel =
            { thxList = []
            , token = "123456"
            , error = Nothing
            , pos = Position 0 0
            }
    in
    Browser.element
        { init = \() -> ( initialModel, getFeed initialModel.token )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


view : Model -> Html Msg
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
    div [] [ thxList model.thxList, err, text (String.fromInt model.pos.x ++ "," ++ String.fromInt model.pos.y) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseMoved (Result.Ok v) ->
            ( { model | pos = v }, Cmd.none )

        MouseMoved (Result.Err _) ->
            ( model, Cmd.none )

        Load ->
            ( model, getFeed model.token )

        ListLoaded (Ok thxList) ->
            ( { model | thxList = thxList }, Cmd.none )

        ListLoaded (Err err) ->
            ( { model | thxList = [], error = Just err }, Cmd.none )


port onMouseMove : (Value -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    onMouseMove mouseMoveToMsg
