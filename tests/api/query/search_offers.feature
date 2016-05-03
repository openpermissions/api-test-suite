# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Offers endpoint

  Background: the "query" service
      Given a "valid" offer
        And the "query" service
        And the "search offers" endpoint


  Scenario: successfully query, but no offers found
      Given an asset not in the repository

       When I bulk query the "query" service for the asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "0"
        And response should not have key "errors"


  Scenario: successfully query, all offers found
      Given an asset has been added for the given offer
        And the asset has been indexed

       When I bulk query the "query" service for the asset

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: successfully query, all offers found using a schema 0 hub key
      Given an asset has been added for the given offer
        And the asset has been indexed

       When I bulk query the "query" service for the asset using a schema 0 hub key

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: successfully query, mixed offers found
      Given an asset has been added for the given offer
        And the asset has been indexed

       When I query the "query" service for the asset together with another asset

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
        And all the errors should have "source" of a repository service


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
        And all the errors should have "source" of a repository service


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
        And all the errors should have "source" of a repository service
