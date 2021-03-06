# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Assets endpoint

  Background: the "onboarding" service
      Given the repository "testco repo" belonging to "testco"
        And "testco" may write to the repository's service

      Given the "auth" service
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting write access to the repository via the "toppco" "onboarding" service

      Given the "onboarding" service
        And the "assets" endpoint for the repository
        And Header "Content-Type" is "application/json; charset=utf-8"
        And Header "Accept" is "application/json"

  Scenario Outline: Onboard different numbers of assets successfully
      Given body is a JSON array with <N> objects

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And I should receive <N> source identifiers to hub keys

    Examples:
      | N       |
      | 1       |
      | 10      |
      | 100     |


  Scenario: Onboard an asset with a custom karma mapping url
      Given body is a JSON array with 1 objects
        And the endpoint has a valid "json" r2rml_url query parameter

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And I should receive 1 source identifiers to hub keys


  @notimplemented
  Scenario Outline: Invalid JSON objects
      Given body is an invalid JSON array with <N> objects

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "<N>" with keys "source message"
        And the errors should contain an object with "source" of "transformation"

    Examples:
      | N    |
      | 1    |
      | 10   |
      | 100  |


  Scenario: JSON too large
      Given body is JSON data that exceeds the maximum allowable size

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "onboarding"
