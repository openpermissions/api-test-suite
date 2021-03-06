# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The agreement endpoint for a given repository

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID

  Scenario: Get an agreement
      Given an agreement for an offer for party "2357111317"
        And the "agreement" endpoint of the repository for the "agreement" "id"
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary"
        And response should not have key "errors"


  Scenario: Get an agreement with the wrong id
      Given an agreement for an offer for party "2357111317"
        And the "agreement" endpoint of the repository for the "offer" "id"
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"

  Scenario: Check that an agreement that does not cover any asset is reported has not covering anything
      Given an agreement for an offer for party "2357111317"
        And the "agreement_coverage" endpoint of the repository for the "agreement" "id"
        And the client has an access token granting "read" access to the repository
        And parameter "asset_ids" is "392139123819,3294203498320914"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary"
