module ModelsSpec exposing (suite)

import Expect exposing (Expectation)
import Fixtures exposing (..)
import Fuzz exposing (Fuzzer, int, list, string)
import Models exposing (TextChunk(..), ThxPartial, filterRecentThxList, filterThxList, updateThxList)
import Test exposing (..)


suite : Test
suite =
    let
        t1 =
            thxFixture 1

        t2 =
            thxFixture 2

        t3 =
            thxFixture 3

        t4 =
            thxFixture 4

        pt4 =
            ThxPartial 4 "update-createdAt" [ Text "updated-text" ]
    in
    describe "ThxList"
        [ describe "func filterThxList"
            [ test "gets same list if id is Nothing" <|
                \_ ->
                    Expect.equal [ t1 ] (filterThxList Nothing [ t1 ])
            , test "gets same list but sorted if id is Nothing" <|
                \_ ->
                    Expect.equal [ t3, t2, t1 ] (filterThxList Nothing [ t1, t3, t2 ])
            , test "gets [t2,t1] if id is 2" <|
                \_ ->
                    Expect.equal [ t2, t1 ] (filterThxList (Just 2) [ t1, t2, t3 ])
            , test "gets [] if id is 0" <|
                \_ ->
                    Expect.equal [] (filterThxList (Just 0) [ t1, t2, t3 ])
            ]
        , describe "func filterRecentThxList"
            [ test "gets [] if id is Nothing" <|
                \_ ->
                    Expect.equal [] (filterRecentThxList Nothing [ t1, t2 ])
            , test "gets [t3] if id is 2" <|
                \_ ->
                    Expect.equal [ t3 ] (filterRecentThxList (Just 2) [ t1, t2, t3 ])
            , test "gets [t3,t2] if id is 1" <|
                \_ ->
                    Expect.equal [ t3, t2 ] (filterRecentThxList (Just 1) [ t3, t1, t2 ])
            ]
        , describe "func updateThxList"
            [ test "gets same list if id was not present" <|
                \_ ->
                    Expect.equal [ t1 ] (updateThxList pt4 [ t1 ])
            , test "updates createdAt and chunks if id was present" <|
                \_ ->
                    let
                        expected =
                            [ { t4 | createdAt = pt4.createdAt, chunks = pt4.chunks } ]
                    in
                    Expect.equal expected (updateThxList pt4 [ t4 ])
            ]
        ]
