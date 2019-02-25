port module Main exposing (main)

import Browser
import Commands exposing (Msg(..), getFeed, getFeedSub, getThxUpdateCmd, updateThxSub)
import Components exposing (error, login, newThx, thxList)
import Html exposing (..)
import Http
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


view : Model -> Browser.Document Msg
view model =
    { body =
        case List.head model.thxList of
            Nothing ->
                [ login model.token "" ]

            Just t ->
                [ thxList model.thxList ]
    , title = "Thanksy - We want people to be appreciated"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load ->
            ( model, getFeed model.token )

        ListLoaded (Ok thxList) ->
            ( { model | thxList = thxList }, Cmd.batch (List.map getThxUpdateCmd thxList) )

        ListLoaded (Err err) ->
            ( { model | thxList = [], error = Just err }, Cmd.none )

        ThxUpdated (Ok thxPartial) ->
            ( { model | thxList = updateThxList thxPartial model.thxList }, Cmd.none )

        TokenChanged token ->
            ( { model | token = token }, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ updateThxSub
        , getFeedSub model.token
        ]
