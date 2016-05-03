# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Offers endpoint for a given repository

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

      Given the "offers" endpoint for the repository

  Scenario: successfully store offer
      Given Header "Content-Type" is "application/ld+json"
        And Header "Accept" is "application/json"
        And request body is a "valid" offer

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" should be a "dictionary" with keys "id"

  Scenario: no data sent
      Given Header "Content-Type" is "application/ld+json"
        And Header "Accept" is "application/json"

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: invalid offer sent
      Given Header "Content-Type" is "application/ld+json"
        And Header "Accept" is "application/json"
        And request body is an "invalid" offer

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"



  Scenario: missing data
      Given Header "Content-Type" is "application/ld+json"
        And Header "Accept" is "application/json"

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: invalid offer sent
      Given Header "Content-Type" is "application/ld+json"
        And Header "Accept" is "application/json"
        And request body is an "invalid" offer

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: Query for the list of offers
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the client has an access token granting "read" access to the repository


       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "offers"
