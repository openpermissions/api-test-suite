# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Licensors endpoint

  Background: the "query" service
      Given the repository "testco repo" belonging to "testco"
        And the "query" service
        And the "licensors" endpoint


  @unstable
  Scenario: successfully retrieve licensor data
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed

       When I query the "query" service for the asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "1" with keys "id name"
        And response should not have key "errors"


  Scenario: no licensor data found for submitted IDs
      Given an asset not in the repository
       When I query the "query" service for the asset

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And response should not have key "data"


  Scenario: successfully retrieve licensor data using a schema 0 hub key
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed

       When I query the "query" service for the asset using a schema 0 hub key

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "1" with keys "id name"
        And response should not have key "errors"


  Scenario: submitting invalid hub key
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "source_id_type" is "hub_key"
        And parameter "source_id" is "an invalid hub key"

       When I make a "GET" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"


  Scenario Outline: missing parameter
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "<parameter>" is "something"

       When I make a "GET" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"

        Examples:

            | parameter      |
            | source_id      |
            | source_id_type |
