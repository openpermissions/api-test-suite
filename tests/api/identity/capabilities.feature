# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Capabilities endpoint

  Background: Set up client service & permissions
      Given the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the "toppco" "identity" service

      Given the "identity" service
        And the "capabilities" endpoint


  Scenario: Retrieve the capabilities of the service
      Given Header "Accept" is "application/json"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "max_id_generation_count"
        And response should not have key "errors"

