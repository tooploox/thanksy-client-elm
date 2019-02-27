module Fixtures exposing (thxFixture, userFixture)

import Models exposing (Thx, User)


userFixture : String -> User
userFixture =
    User "realName" "avatarUrl" "name"


thxFixture : Int -> Thx
thxFixture id =
    { receivers = [ userFixture "receiver-1" ]
    , giver = userFixture "giver-1"
    , id = id
    , createdAt = "createdAt"
    , loveCount = 0
    , confettiCount = 1
    , clapCount = 2
    , wowCount = 3
    , text = "text"
    , chunks = []
    }
