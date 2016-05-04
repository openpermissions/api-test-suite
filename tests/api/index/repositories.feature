# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Query the repositories of an entity in the index

  Background:
      Given the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the "toppco" "index" service

  Scenario Outline: Retrieve repositories of an entity in the index
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed
        And the "index" service
        And the "<entity-repositories>" endpoint
        And Header "Accept" is "application/json"

       When I make a "GET" request with the id_map <id>

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "repositories"
        And each element of "data/repositories" has attributes "repository_id,entity_id"
        And response should not have key "errors"

    Examples:
    | entity-repositories                                             | id        |
    | entity-types/asset/id-types/hub_key/ids/{}/repositories         | hub_key   |
    | entity-types/asset/id-types/testcopictureid/ids/{}/repositories | source_id |


  Scenario Outline: Retrieve repositories of an entity not in the index
      Given the "index" service
        And the "<entity-repositories>" endpoint
        And Header "Accept" is "application/json"

       When I make a "GET" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "data"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "index"

    Examples:
    | entity-repositories                                                           |
    | entity-types/asset/id-types/hub_key/ids/some_missing_value/repositories       |
    | entity-types/asset/id-types/testcopictureid/ids/testco01_missing/repositories |


  @notimplemented
  Scenario Outline: Retrieve repositories of an entity that has none in the index
      Given the "index" service
        And the "<entity-repositories>" endpoint
        And Header "Accept" is "application/json"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "0"
        And response should not have key "errors"

    Examples:
    | entity-repositories                                                   |
    | entity-types/asset/id-types/chub/ids/some_value/repositories          |
    | entity-types/asset/id-types/testcopictureid/ids/testco01/repositories |
    | entity-types/asset/id-types/testcopictureid/ids/1010101/repositories  |
