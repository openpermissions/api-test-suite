# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Create agreements in the repository
  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository


  Scenario: Transform an offer in an agreement
      Given a "valid" offer
        And an asset has been added for the given offer
        And the "agreements" endpoint for the repository
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "43943423923"

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"

  Scenario: Transform an offer in an agreement and metadata transaction are provided
      Given a "valid" offer
        And an asset has been added for the given offer
        And the "agreements" endpoint for the repository
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "43943423923"
        And request body has a key of "metadata" with a value of '{"payAmount":"10GBP- ACCOUNT 123456- TRANSACTION 123"}'

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"

  Scenario: Failing to transform an offer in an agreement when no asset provided (indirect asset)
      Given a "valid" offer
        And an indirect asset has been added for the given offer
        And the "agreements" endpoint
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "43943423923"

       When I make a "POST" request

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"

  Scenario: Transform an offer in an agreement when an asset is provided (indirect asset)
      Given a "valid" offer
        And an indirect asset has been added for the given offer
        And the "agreements" endpoint for the repository
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "43943423923"
        And request body has a key of "asset_ids" is a singleton id_map entity_id

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "id"

  Scenario: Invalid metadata raises validation exception
       Given a "valid" offer
        And an asset has been added for the given offer
        And the "agreements" endpoint for the repository
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "43943423923"
        And request body has a key of "metadata" with a value of '{"payAmounzxcxzct":"10GBP- ACCOUNT 123456- TRANSACTION 123"}'

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of the repository service "name"
