# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Search for repositories containing entities

  Background:
      Given the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the "toppco" "index" service

  Scenario: Retrieve repositories
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed
        And the "index" service
        And the "asset" endpoint
        And Header "Accept" is "application/json"
        And the body is an array containing the following asset ID types
            | source_id_type  |
            | hub_key         |
            | testcopictureid |

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And an object with array "data" of size "2"
        And each object in the array has a "repositories" array of size "1"


  Scenario: Retrieve repositories for an unindexed ID
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed
        And the "index" service
        And the "asset" endpoint
        And Header "Accept" is "application/json"
        And the body is an array containing an unindexed id

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And an object with array "data" of size "1"
        And each object in the array has a "repositories" array of size "0"
