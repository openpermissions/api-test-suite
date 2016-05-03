# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Get a client credentials token

  Background: Set up services & permissions
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And "testco" has an approved "external" service
        And "testco" has an approved "onboarding" service
        And "testco" has an approved "repository" service
        And the repository "testco repo" belonging to "testco"
        And "developerco" has an approved "external" service
        And "developerco" may write to the repository
        And "developerco" may write to the "testco" "onboarding" service

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And Header "Accept" is "application/json"
        And the client ID is the "developerco" "external" service ID


  Scenario: Get an access token
      Given the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And the response should contain JWT "access_token"
        And the JWT "sub" should be the client ID
        And the JWT "scope" should be "read"


  Scenario: Get an access token to write to a repository
      Given the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"
        And the scope is to write to the repository

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And the response should contain JWT "access_token"
        And the JWT "sub" should be the client ID
        And the JWT "scope" should be the scope


  Scenario: Get an access token to write to a service
      Given the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"
        And the scope is to write to the "testco" "onboarding" service

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And the response should contain JWT "access_token"
        And the JWT "sub" should be the client ID
        And the JWT "scope" should be the scope


  Scenario: Get an access token to write to a service that does not exist
      Given the request is authenticated with the client ID and secret
        And parameter "scope" is "write[does_not_exist]"
        And parameter "grant_type" is "client_credentials"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400


  Scenario: Get a delegate token to write to a repository
      Given the "auth" service
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"
        And the scope is to write to the repository via the "testco" "onboarding" service

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And the response should contain JWT "access_token"
        And the JWT "sub" should be the client ID
        And the JWT "scope" should be the scope


  Scenario: Get a delegate token for a repository
      Given the request is authenticated with the client ID and secret
        And the scope is to delegate to a repository
        And parameter "grant_type" is "client_credentials"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
            # Because the delegate should be a service not a repository
        And response should have key "status" of 400


  Scenario: Get a token to delegate to a service that does not exist
      Given the request is authenticated with the client ID and secret
        And the scope is to delegate to a service that does not exist
        And parameter "grant_type" is "client_credentials"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
            # Because the delegate should be a service not a repository
        And response should have key "status" of 400


  Scenario: Unauthorised to access repository
      Given the "accounts" service
        And "developerco" cannot access the repository

      Given the "auth" service
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"
        And the scope is to write to the repository

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403


  Scenario: Unauthorised to access repository's service
      Given the "accounts" service
        And "developerco" cannot access the repository's service

      Given the "auth" service
        And the request is authenticated with the client ID and secret
        And parameter "grant_type" is "client_credentials"
        And the scope is to write to the repository service

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "403" response code
        And response should have key "status" of 403


  Scenario: Invalid grant type
      Given the request is authenticated with the client ID and secret
        And parameter "grant_type" is "invalid"

       When I make a "POST" request to the "token" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
