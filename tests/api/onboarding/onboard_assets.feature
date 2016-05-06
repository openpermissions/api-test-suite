# Copyright 2016 Open Permissions Platform Coalition
#
# Licensed under the Apache License, Version 2.0 (the "License");
#
# you may not use this file except in compliance with the License. You may
# obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

Feature: The Assets endpoint

  Background: the "onboarding" service
      Given the repository "testco repo" belonging to "testco"
        And "testco" may write to the repository's service

      Given the "auth" service
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting write access to the repository via the "toppco" "onboarding" service

      Given the "onboarding" service
        And the "assets" endpoint for the repository
        And Header "Accept" is "application/json"

    Scenario: Missing Content-Type header

       When I make a "POST" request

       Then I should receive a "415" response code
        And response should have key "status" of 415
        And response header "Content-Type" should be "application/json; charset=UTF-8"
