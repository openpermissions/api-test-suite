# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Send notifications to the index to ask it to update its index on specified repo

  Background: the "index" service
      Given the "index" service
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the "toppco" "index" service


  Scenario: Send a notification to the server and have it accepted
      Given parameter "id" is "a repo ID"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "notifications" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"

  Scenario: Send a notification without a service ID
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "notifications" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "errors"
