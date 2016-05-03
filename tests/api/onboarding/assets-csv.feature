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
        And the client has an access token granting write access to the repository via the "hogwarts" "onboarding" service

      Given the "onboarding" service
        And the "assets" endpoint for the repository


  Scenario Outline: Onboard different numbers of assets successfully
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"
        And body is csv data with <N> rows of data

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
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"
        And the endpoint has a valid "csv" r2rml_url query parameter
        And body is csv data with 1 rows of data

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And I should receive 1 source identifiers to hub keys


  @notimplemented
  Scenario: No data in POST body
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source line message"
        And the errors should contain an object with "source" of "transformation"


  @notimplemented
  Scenario Outline: Missing CSV headers
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"
        And body is csv data with <problem>

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source line message"
        And the errors should contain an object with "source" of "transformation"

    Examples:
      | problem           |
      | no header         |
      | incomplete header |


  @notimplemented
  Scenario Outline: Invalid CSV rows
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"
        And body is csv data with <N> invalid rows

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "<N>" with keys "source line message"
        And the errors should contain an object with "source" of "transformation"

    Examples:
      | N    |
      | 1    |
      | 10   |
      | 100  |


  Scenario: CSV too large
      Given Header "Content-Type" is "text/csv; charset=utf-8"
        And Header "Accept" is "application/json"
        And body is csv data that exceeds the maximum allowable size

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "onboarding"
