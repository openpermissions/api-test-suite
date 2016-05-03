# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Access a resource with a client credentials token

  Background:
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And "testco" has an approved "repository" service
        And "testco" has an approved "onboarding" service
        And the repository "testco repo" belonging to "testco"


  Scenario: Authorized to read a service
      Given "developerco" may read from the "testco" "repository" service
        And "developerco" has an approved "external" service
        And requested an access token to "read"

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "r"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True

  Scenario: Authorized to write to a service
      Given "developerco" may write to the "testco" "repository" service
        And "developerco" has an approved "external" service
        And requested an access token to write to the "testco" "repository" service

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True

  Scenario: Authorized to read a repository
      Given "developerco" may read from the repository
        And "developerco" may read from the repository's service
        And "developerco" has an approved "external" service
        And requested an access token to "read"

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "r"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True

  Scenario: Authorized to write to a repository
      Given "developerco" may write to the repository
        And "developerco" may write to the repository's service
        And "developerco" has an approved "external" service
        And requested an access token to write to the repository

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of True

  Scenario: Wrong requested access (read)
      Given "developerco" may read the "testco" "repository" service
        And "developerco" has an approved "external" service
        And requested an access token to "read"

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Wrong requested access (write)
      Given "developerco" may write to the "testco" "repository" service
        And "developerco" has an approved "external" service
        And requested an access token to write to the "testco" "repository" service

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "r"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: No longer authorized to write
      Given "developerco" may write to the repository
        And "developerco" has an approved "external" service
        And requested an access token to write to the repository
        And "developerco" cannot access the repository

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Repository not hosted by the service
      Given "developerco" may write to the repository
        And "developerco" has an approved "external" service
        And requested an access token to write to the repository

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Wrong service
      Given "developerco" may write to the "testco" "onboarding" service
        And "developerco" has an approved "external" service
        And requested an access token to write to the "testco" "onboarding" service

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Invalid access token
      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "repository" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is "invalid"
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Wrong resource_id
      Given "developerco" may write to the "testco" "onboarding" service
        And "developerco" has an approved "external" service
        And requested an access token to write to the "testco" "onboarding" service

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco" "onboarding" service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"
        And parameter "resource_id" is "testco repo" repository's ID

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Missing resource_id (only checks the client id if not included)
      Given "developerco" may write to the repository
        And "developerco" has an approved "external" service
        And requested an access token to write to the repository

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response should have key "has_access" of False

  Scenario: Missing token
      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "requested_access" is "w"

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "400" response code

  Scenario: Missing requested_access
      Given "developerco" may write to the repository
        And "developerco" has an approved "external" service
        And requested an access token to write to the repository

      Given the "auth" service
        And Header "Content-Type" is "application/x-www-form-urlencoded"
        And the client ID is the "testco repo" repository's service ID
        And the request is authenticated with the client ID and secret
        And parameter "token" is the access_token

       When I make a "POST" request to the "verify" endpoint

       Then I should receive a "400" response code
