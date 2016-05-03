# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Asset IDs endpoint

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

        And a "valid" offer
        And an asset has been added for the given offer

        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"


  Scenario Outline: successfully add new IDs
      Given a body of <N> generated valid ids
        And the additional IDs endpoint for the new asset

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"

    Examples:
      | N |
      | 1 |
      | 4 |


  Scenario Outline: add new ids with missing data
      Given a body of <N> generated invalid ids
        And the additional IDs endpoint for the new asset

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "<N>" with keys "message source"
        And the errors should contain an object with "source" of the repository service "name"

    Examples:
      | N |
      | 1 |
      | 4 |


  Scenario Outline: add new ids for an asset that does not exist
      Given a body of <N> generated valid ids
        And the additional IDs endpoint for an illegal asset

       When I make a "POST" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "message source"
        And the errors should contain an object with "source" of the repository service "name"

    Examples:
      | N |
      | 1 |
      | 4 |


  # TODO: functionality to validate id type
  @notimplemented
  Scenario Outline: add new ids with illegal id type
      Given a body of <N> generated invalid id types
        And the additional ids endpoint for the new asset

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "<N>" with keys "message source"
        And the errors should contain an object with "source" of the repository service "name"

    Examples:
      | N |
      | 1 |
      | 4 |
