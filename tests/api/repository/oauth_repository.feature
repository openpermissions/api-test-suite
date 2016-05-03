# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Access repositories that are authenticated with oauth
  """
  Only testing negative oauth paths as positive paths are covered when testing individual endpoints.
  """

  Background: Setup a user, organisation, service
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And the repository "testco repo" belonging to "testco"

      Given the client ID is the "testco" "external" service ID
        And "testco" may write to the repository
        And "testco" may write to the repository's service

      Given the "repository" service


  Scenario: Connect to repository endpoint requiring auth with no token
      Given there is no access token
        And the "assets" endpoint for the repository

       When I make a "POST" request with the repository id

       Then I should receive a "401" response code
        And response should have key "status" of 401


  Scenario: Connect to repository endpoint requiring write auth with read token
      Given the client has an access token granting "read" access to the repository
        And the "assets" endpoint for the repository

       When I make a "POST" request with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403


  Scenario: Connect to repository endpoint requiring read auth with write token
      Given the client has an access token granting "write" access to the repository
        And the "identifiers" endpoint for the repository

       When I make a "GET" request

       Then I should receive a "403" response code
        And response should have key "status" of 403


  Scenario: Connect to repository endpoint requiring auth with token for service
      Given the client has an access token granting "write" access to the "hogwarts" "repository" service
        And the "assets" endpoint for the repository

       When I make a "POST" request with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403