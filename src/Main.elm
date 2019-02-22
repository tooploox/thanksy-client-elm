module Main exposing (main)

import Browser
import Components exposing (thxList)
import Html exposing (..)
import Http
import Models exposing (Msg(..), TextChunk(..), Thx, User, getFeed)


type alias Model =
    { thxList : List Thx
    , token : String
    , error : Maybe Http.Error
    }


main : Program () Model Msg
main =
    let
        initialModel : Model
        initialModel =
            { thxList = []
            , token = "123456"
            , error = Nothing
            }
    in
    Browser.element
        { init = \() -> ( initialModel, getFeed initialModel.token )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
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
    div [] [ thxList model.thxList, err ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getFeed model.token )

        ListLoaded maybeList ->
            case maybeList of
                Ok thxList ->
                    ( { model | thxList = thxList }, Cmd.none )

                Err err ->
                    ( { model | thxList = [], error = Just err }, Cmd.none )
