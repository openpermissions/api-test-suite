# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Access a resource with delegated authorization

  Background:
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And "testco" has an approved "repository" service
        And "testco" has an approved "onboarding" service
        And "testco" has an approved "external" service
        And the repository "testco repo" belonging to "testco"
        And "developerco" has an approved "external" service
        And "developerco" may write to the "testco" "external" service
        And "developerco" may write to the repository
        And "developerco" may write to the repository's service

  Scenario: Authorize delegate access to repository
      Given the "auth" service
        And the client ID is the "developerco" "external" service ID
        And the client has an access token granting write access to the repository via the "testco" "onboarding" service

      Given the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is the access_token
        And the scope is to write to the repository
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the response_object access_token
        And parameter "requested_access" is "w"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True

  Scenario: Authorize delegate access to service
      Given the "auth" service
        And the client ID is the "developerco" "external" service ID
        And the client has an access token granting write access to the "testco" "onboarding" service via the "testco" "external" service

      Given the client ID is the "testco" "external" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is the access_token
        And the scope is to write to the "testco" "onboarding" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the response_object access_token
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True
