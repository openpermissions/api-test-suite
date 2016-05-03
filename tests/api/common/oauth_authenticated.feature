# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Access services that are authenticated with oauth
  """
  Only testing negative oauth paths as positive paths are covered when testing individual endpoints.
  """

  Background: Setup a user, organisation, service
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in

      Given the client ID is the "testco" "external" service ID


  Scenario Outline: Connect to service with no token
      Given the "<service>" service
        And "testco" may read from the "hogwarts" "<service>" service
        And "testco" may write to the "hogwarts" "<service>" service

        And there is no access token

       When I make a "<method>" request to the "<endpoint>" endpoint

       Then I should receive a "401" response code
        And response should have key "status" of 401

        Examples:
        | service        | endpoint                                                | method |
        | identity       | capabilities                                            | GET    |
        | identity       | asset                                                   | POST   |
        | index          | entity-types/asset/id-types/hub_key/ids/S1/repositories | GET    |
        | index          | notifications                                           | POST   |
        | onboarding     | capabilities                                            | GET    |
        | onboarding     | assets                                                  | POST   |
        | repository     | capabilities                                            | GET    |
        | transformation | capabilities                                            | GET    |
        | transformation | assets                                                  | POST   |


  Scenario Outline: Connect to service requiring read oauth with write token
      Given the "<service>" service
        And "testco" may write to the "hogwarts" "<service>" service
        And the client has an access token granting "write" access to the "hogwarts" "<service>" service

       When I make a "GET" request to the "<endpoint>" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403

        Examples:
        | service        | endpoint                                                |
        | identity       | capabilities                                            |
        | index          | entity-types/asset/id-types/hub_key/ids/S1/repositories |
        | onboarding     | capabilities                                            |
        | repository     | capabilities                                            |
        | transformation | capabilities                                            |


  Scenario Outline: Connect to service requiring write oauth with read token
      Given the "<service>" service
        And "testco" may read from the "hogwarts" "<service>" service
        And the client has an access token granting "read" access

       When I make a "POST" request to the "<endpoint>" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403

        Examples:
        | service        | endpoint      |
        | identity       | asset         |
        | index          | notifications |
        | onboarding     | assets        |
        | transformation | assets        |

