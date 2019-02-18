module Models exposing (Msg(..), TextChunk(..), Thx, User, getFeed)

import Browser
import Debug
import Html exposing (Html, button, div, input, p, text)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..), Response, get)
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)
import List
import Task
import Url.Builder as Url


type alias User =
    { realName : String
    , avatarUrl : String
    , name : String
    , id : String
    }


type TextChunk
    = Text String
    | Nickname String
    | Emoji String String


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "real_name" Decode.string
        |> required "avatar_url" Decode.string
        |> required "name" Decode.string
        |> required "id" Decode.string


type alias Thx =
    { receivers : List User
    , giver : User
    , id : Int
    , createdAt : String
    , loveCount : Int
    , confettiCount : Int
    , clapCount : Int
    , wowCount : Int
    , chunks : List TextChunk
    }


thxDecoder : Decoder Thx
thxDecoder =
    Decode.succeed Thx
        |> required "receivers" (Decode.list userDecoder)
        |> required "giver" userDecoder
        |> required "id" Decode.int
        |> required "createdAt" Decode.string
        |> required "love_count" Decode.int
        |> required "confetti_count" Decode.int
        |> required "clap_count" Decode.int
        |> required "wow_count" Decode.int
        |> hardcoded []


type Msg
    = Load
    | LoadFeed (Result Http.Error (List Thx))


getFeed : String -> Cmd Msg
getFeed token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = "https://thanksy.herokuapp.com/thanks/list"
        , body = Http.emptyBody
        , expect = Http.expectJson (Decode.list thxDecoder)
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send LoadFeed
