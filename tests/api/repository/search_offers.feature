# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Offers endpoint

  Background: the "repository" service
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID

      Given the client has an access token granting "write" access to the repository
        And a "valid" offer
        And an asset has been added for the given offer

      Given the "search offers" endpoint for the repository
        And the client has an access token granting "read" access to the repository


  Scenario: successfully query, but no offers found
      Given an asset not in the repository

       When I bulk query the "repository" service for the asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "0"
        And response should not have key "errors"


  Scenario: successfully query, all offers found
       When I bulk query the "repository" service for the asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: successfully query, mixed offers found
       When I query the "repository" service for the asset together with another asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  # TODO: validation of body in the repository service
  @notimplemented
  Scenario: submit no data
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  # TODO: functionality to validate id type
  @notimplemented
  Scenario: submit invalid asset id type
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And an array of "1" "invalid id type" Query objects as the body

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  # TODO: validation of body in the repository service
  @notimplemented
  Scenario: submit an invalid Query object
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And an invalid Query objects as the body

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: Get an offer
      Given the "offer" endpoint of the repository for the "offer" "id"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary"
        And response should not have key "errors"


  Scenario: Get an offer with the wrong id
      Given a "non-existent" offer
        And the "offer" endpoint of the repository for the "offer" "id"

       When I make a "GET" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"
