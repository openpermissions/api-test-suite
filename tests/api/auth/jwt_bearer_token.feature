# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Get a token authorized with a JWT

  Background: Set up services & permissions, and get a JWT
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And "testco" has an approved "external" service
        And "testco" has an approved "onboarding" service
        And "testco" has an approved "repository" service
        And the repository "testco repo" belonging to "testco"
        And "developerco" has an approved "external" service
        And "developerco" may write to the repository

      Given the "auth" service
        And the client ID is the "developerco" "external" service ID
        And the client has an access token granting write access to the repository via the "testco" "onboarding" service
    Scenario: Get an access token with a delegate JWT
      Given the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is the access_token
        And the scope is to write to the repository
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And the response should contain JWT "access_token"
        And the JWT "sub" should be the client ID
        And the JWT scope should be to write to the repository

    Scenario: Request token with another service's delegate token
      Given the client ID is the "testco" "external" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is the access_token
        And the scope is to write to the repository
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403

    Scenario: Request token to write to a different resource
      Given the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is the access_token
        And the scope is to write to the repository service
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403

    Scenario: Request token without an assertion
      Given the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And the scope is to write to the repository
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400

    Scenario: Request token with an invalid assertion
      Given the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "urn:ietf:params:oauth:grant-type:jwt-bearer"
        And parameter "assertion" is "invalid"
        And the scope is to write to the repository
        And Header "Content-Type" is "application/x-www-form-urlencoded"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
