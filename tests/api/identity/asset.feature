# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Asset endpoint

  Background:
      Given the "identity" service
        And the "asset" endpoint
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the "toppco" "identity" service
        And parameter "resolver_id" is "https://openpermissions.org"
        And parameter "hub_id" is "hub1"
        And parameter "repository_id" is "10e4b9612337f237118e1678ec001fa6"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"


  Scenario: generate a valid hub_key (without 'count' uses default 1)

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "1"
        And response should not have key "errors"


  Scenario: generate a valid set of hub_keys from a count

      Given parameter "count" is integer "4"

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "4"
        And response should not have key "errors"


  Scenario Outline: missing one parameter

      Given parameter "<param>" is left out

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "identity"
      
      Examples:
        | param         |
        | resolver_id   |
        | hub_id        |
        | repository_id |



  Scenario: missing Content-Type and Accept - JSON is assumed

      Given Header "Content-Type" is left out
        And Header "Accept" is left out

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "string"
        And response should not have key "errors"
