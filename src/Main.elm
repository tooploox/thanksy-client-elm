port module Main exposing (Flags, Model, config)

import Browser
import Commands exposing (ApiState(..), Msg(..), getFeed, getFeedSub, getThxUpdateCmd, setToken, toApiState, updateNewThxSub, updateThxSub)
import Components exposing (error, login, newThx, thxList)
import Html exposing (..)
import Http exposing (Error(..))
import List.Extra
import Models exposing (TextChunk(..), Thx, ThxPartial, ThxPartialRaw, User, filterRecentThxList, filterThxList, updateThxList)
import Monitor


config :
    { init : Flags -> ( Model, Cmd Msg )
    , view : Model -> Browser.Document Msg
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , subscriptions : Model -> Sub Msg
    }
config =
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


type alias Model =
    { thxList : List Thx
    , recentThxList : List Thx
    , lastThxId : Maybe Int
    , token : String
    , isTokenFresh : Bool
    , apiUrl : String
    , apiState : ApiState
    , apiError : Maybe Error
    }


type alias Flags =
    { token : String, apiUrl : String }


initialModel : Model
initialModel =
    { thxList = []
    , recentThxList = []
    , lastThxId = Nothing
    , token = ""
    , isTokenFresh = True
    , apiState = Empty
    , apiError = Nothing
    , apiUrl = ""
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { initialModel | token = flags.token, apiUrl = flags.apiUrl }, getFeed flags.apiUrl flags.token )


toError : Model -> String
toError model =
    if model.apiState == NoResponse then
        "No API response. Are we online?"

    else if model.apiState == InvalidToken && not model.isTokenFresh && not (String.isEmpty model.token) then
        "Security code is not valid"

    else
        ""


view : Model -> Browser.Document Msg
view model =
    { body =
        case List.head model.thxList of
            Nothing ->
                [ login model.token (toError model) ]

            _ ->
                [ thxList model.thxList, newThx model.recentThxList ]
    , title = "Thanksy - We want people to be appreciated"
    }


updateThxLists : Model -> List Thx -> Model
updateThxLists model ts =
    let
        newLastThxId =
            case ( model.lastThxId, List.Extra.getAt 1 ts ) of
                ( Nothing, Just t ) ->
                    Just t.id

                ( Nothing, Nothing ) ->
                    Nothing

                _ ->
                    model.lastThxId
    in
    { model
        | thxList = filterThxList model.lastThxId ts
        , recentThxList = filterRecentThxList model.lastThxId ts
        , lastThxId = newLastThxId
        , apiState = Empty
        , isTokenFresh = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        id =
            ( model, Cmd.none )
    in
    case msg of
        TokenChanged token ->
            ( { model | token = token, isTokenFresh = True }, setToken token )

        Login ->
            ( { model | apiState = TokenNotChecked }, getFeed model.apiUrl model.token )

        Load ->
            if model.apiState == Empty || model.apiState == TokenNotChecked then
                ( { model | isTokenFresh = False }, getFeed model.apiUrl model.token )

            else
                id

        TickLastId ->
            case model.lastThxId of
                Just _ ->
                    ( updateThxLists model (List.append model.recentThxList model.thxList)
                    , Cmd.none
                    )

                _ ->
                    id

        ListLoaded (Ok thxList) ->
            ( updateThxLists model thxList, Cmd.batch (List.map getThxUpdateCmd thxList) )

        ListLoaded (Err err) ->
            ( { model | isTokenFresh = False, thxList = [], apiError = Just err, apiState = toApiState err }, Cmd.none )

        ThxUpdated (Ok thxPartial) ->
            ( { model
                | thxList = updateThxList thxPartial model.thxList
                , recentThxList = updateThxList thxPartial model.recentThxList
              }
            , Cmd.none
            )

        _ ->
            id


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ updateThxSub
        , getFeedSub model.token
        , updateNewThxSub
        ]
