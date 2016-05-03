# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Restrictions on service endpoint

  Background: the "accounts" service
      Given the "accounts" service
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

      Given the existing organisation "testco"
        And the organisation has an "external" service


  Scenario: Anonymous user get a service should not see the permissions

      Given Header "Authorization" is empty

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response "data" should be an object without "permissions"


  Scenario: Testco user get a testco service should see the permissions

      Given the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response "data" should be an object with "permissions" of type "list"


  Scenario: Hogwarts user get a testco service should not see the permissions

      Given the existing user "cuthbert"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response "data" should be an object without "permissions"


  Scenario: Global admin get a service should see the permissions

      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response "data" should be an object with "permissions" of type "list"