-- Fixtures


module Fixtures exposing (thxFixture, thxListFixture)

import Api exposing (Thx, User)


thxListFixture =
    let
        delta =
            \i -> \f -> { f | createdAt = "Today - " ++ String.fromInt i, id = i }
    in
    List.repeat 10 thxFixture |> List.indexedMap delta


thxFixture : Thx
thxFixture =
    let
        receivers : List User
        receivers =
            [ User "Evan.Czaplicki" "https://avatars3.githubusercontent.com/u/1658058?s=460&v=4" "evan" "id-1"
            , User "Richard Feldman" "https://avatars1.githubusercontent.com/u/1094080?s=460&v=4" "richard" "id-2"
            ]

        chunks : List TextChunk
        chunks =
            [ Text "Thanks for Elm "
            , Nickname "@Evan.Czaplicki"
            , Text " "
            , Nickname "@Richard.Feldman"
            , Text " "
            , Emoji "https://twemoji.maxcdn.com/2/72x72/1f4fa.png" "📺"
            ]
    in
    { id = 0
    , receivers = receivers
    , giver = User "Grzegorz Moskal" "https://avatars2.githubusercontent.com/u/1741736?s=88&v=4" "greg" "id-3"
    , createdAt = "Today 10:08 AM"
    , loveCount = 0
    , confettiCount = 1
    , clapCount = 2
    , wowCount = 3
    , chunks = chunks
    }
