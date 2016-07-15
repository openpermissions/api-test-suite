# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Assets endpoint

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

      Given the "assets" endpoint for the repository


  Scenario Outline: successfully store assets
      Given Header "Content-Type" is "<content_type>"
        And Header "Accept" is "application/json"
        And body is a "valid" <data_format> asset

       When I make a "POST" request with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"

      Examples:
        | content_type        | data_format |
        | application/xml     | xml         |
        | text/rdf+n3         | turtle      |
        | application/ld+json | json-ld     |


  Scenario: Missing Content-Type
      Given Header "Accept" is "application/json"
        And body is a "valid" xml asset

       When I make a "POST" request with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"


  Scenario: no data sent
      Given Header "Content-Type" is "application/xml"
        And Header "Accept" is "application/json"

       When I make a "POST" request with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: invalid XML sent
      Given Header "Content-Type" is "application/xml"
        And Header "Accept" is "application/json"
        And body is an "invalid" xml asset

       When I make a "POST" request with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: not XML sent
      Given Header "Content-Type" is "application/xml"
        And Header "Accept" is "application/json"
        And body is "not" an xml asset

       When I make a "POST" request with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"
