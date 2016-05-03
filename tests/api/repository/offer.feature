# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Offer endpoint for a given repository

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository


  Scenario: Get an offer
      Given a "valid" offer
        And the "offer" endpoint of the repository for the "offer" "id"
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary"
        And response should not have key "errors"

  Scenario: List available offers in a repo
      Given a "valid" offer
        And the "offers" endpoint for the repository
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"



  Scenario: Get an offer with the wrong id
      Given a "non-existent" offer
        And the "offer" endpoint of the repository for the "offer" "id"
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"


  Scenario: Expire an offer
      Given a "valid" offer
        And the "offer" endpoint of the repository for the "offer" "id"
        And request body has a key of "expires" with a value of "1999-12-31T23:59:59Z"

       When I make a "PUT" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"
        And response "data" should be a "dictionary" with key "expires"
        #And response "data" has a key "expires" equals "1999-12-31T23:59:59Z"


  Scenario: Expire an offer with invalid expiry date
      Given a "valid" offer
        And the "offer" endpoint of the repository for the "offer" "id"
        And request body has a key of "expires" with a value of "invalid"

       When I make a "PUT" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"


  Scenario: Expire an offer which has already been expired
      Given an "expired" offer
        And the "offer" endpoint of the repository for the "offer" "id"
        And request body has a key of "expires" with a value of "1999-12-31T23:59:59Z"

       When I make a "PUT" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"

