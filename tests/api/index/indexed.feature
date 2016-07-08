# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Retrieve last indexed timestamp for a respository

  Background:
      Given the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the "toppco" "index" service


  Scenario: Retrieve last indexed timestamp for repository
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed
        And the "index" service

       When I make a "GET" request to the "indexed" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And the response should contain "last_indexed" of type "string"


  Scenario: Retrieve last indexed timestamp for an unknown repository
      Given the "index" service
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "indexed" endpoint with "unknown_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "index"
