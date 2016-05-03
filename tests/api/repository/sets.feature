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



  Scenario: Create a set without providing it a title
      Given the "sets" endpoint for the repository

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"



  Scenario: Create a set without providing with a title
      Given the "sets" endpoint for the repository
        And parameter "feature" is "spring picture collection 2016"

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"


  Scenario: Retrieve the list of sets
      Given a set
        And the "sets" endpoint for the repository
        And the client has an access token granting "read" access to the repository

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "sets"



  Scenario: Put 2500 assets into a set
      Given a set
        And a group of 2500 asset ids
        And the "set assets" endpoint of the repository for the "set" "id"
        and parameter "assets" is the set_asset_ids

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"


  Scenario: Retrieve a set
      Given a set with 10 assets
        And the client has an access token granting "read" access to the repository
        And the "set" endpoint of the repository for the "set" "id"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"


  Scenario: Delete a set
      Given a set with 100 assets
        And the "set assets" endpoint of the repository for the "set" "id"

       When I make a "DELETE" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"


  Scenario: Check an asset exists in a set
      Given a set with 100 assets
        And the client has an access token granting "read" access to the repository
        And the "set asset" endpoint for the "set" "id" with the asset "0"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And  response "data" should be an object with "is_member" of value True


  Scenario: List assets in a set
      Given a set with 16 assets
        And the client has an access token granting "read" access to the repository
        And the "set assets" endpoint of the repository for the "set" "id"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"


  Scenario: Add an asset to a set
      Given a set
        And a group of 1 asset ids
        And the "set asset" endpoint for the "set" "id" with the asset "0"

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"


  Scenario: Delete an asset exists from a set
      Given a set with 20 assets
        And the "set asset" endpoint for the "set" "id" with the asset "0"

       When I make a "DELETE" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
