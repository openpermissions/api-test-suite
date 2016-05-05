# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Repositories endpoint

  Background: the "accounts" service
      Given the "accounts" service
        And the existing user "harry"
        And the user is logged in
        And the existing organisation "toppco" with a "repository" service
        And the service contains a repository owned by the organisation
        And the service is approved


  Scenario: Get repositories for an organisation
       When I make a "GET" request to the "organisation repositories" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: Get all repositories
    When I make a "GET" request to the "repositories" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: Get a repository by id
      Given Header "Accept" is "application/json"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: Get a repository with an ID for another type of resource
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "repository" endpoint with the organisation id

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

  Scenario: Org admin update repository
      Given Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And parameter "permissions" is a valid set of repository permissions
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: Global admin update repository
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And parameter "permissions" is a valid set of repository permissions
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"

        And response should not have key "errors"


  Scenario: Repository owner admin update repository
      Given Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And parameter "permissions" is a valid set of repository permissions
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario Outline: Partially update repository
      Given Header "Authorization" is a valid token
        And parameter "<param>" is <value>
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"

        Examples:
            | param           | value                              |
            | name            | a unique string                    |
            | organisation_id | the organisation id                |
            | permissions     | a valid set of repository permissions  |


  Scenario: Update the repository's service
      Given the existing organisation "testco"
        And the organisation has a "repository" service
        And parameter "service_id" is the service id
        And the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "/data/state" should be "pending"

  Scenario: Update repository with a service that does not exist
      Given parameter "name" is a unique string
        And parameter "service_id" is "a service that does not exist"
        And parameter "organisation_id" is the organisation id
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update repository with an organisation that does not exist
      Given parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is "an organisation that does not exist"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update repository with an invalid permissions
      Given parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "permissions" is "invalid.permissions"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthenticated update of repository
      Given parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation attempt to update repository
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User of an organisation attempt to update repository service id
      Given a new user
        And the user is logged in
        And the user has joined the organisation
        And Header "Authorization" is a valid token
        And parameter "service_id" is the service id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User of an organisation attempt to update repository state
      Given a new user
        And the user is logged in
        And the user has joined the organisation
        And Header "Authorization" is a valid token
        And parameter "state" is "approved"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Service owner attempt to update repository state
      Given Header "Authorization" is a valid token
        And parameter "state" is "approved"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"


  Scenario: Service owner attempt to update repository service id
      Given Header "Authorization" is a valid token
        And parameter "service_id" is the service id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"


  Scenario: User not admin for organisation attempt to update repository
      Given the existing user "cuthbert"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_id" is the service id
        And parameter "organisation_id" is the organisation id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Org Admin Delete an approved repository
      Given Header "Authorization" is a valid token
        And the service contains a repository owned by the organisation

       When I make a "DELETE" request to the "repository" endpoint with the repository id
       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"


  Scenario: Global Admin Delete an approved repository
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "repository" endpoint with the repository id
       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"


  Scenario: Repository owner Delete an approved repository
      Given Header "Authorization" is a valid token

       When I make a "DELETE" request to the "repository" endpoint with the repository id
       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"


  Scenario: Repository owner Delete a pending repository

      Given the existing user "cuthbert"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the service contains a repository owned by the organisation

       When I make a "DELETE" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Delete a repository that doesn't exist
      Given Header "Authorization" is a valid token

       When I make a "DELETE" request to the "repository" endpoint with "an_invalid_repository_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthorized delete a repository
       When I make a "DELETE" request to the "repository" endpoint with the repository id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "repository" endpoint with the repository id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: User not part of organisation attempt to delete a repository
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response should not have key "errors"


  Scenario: User not admin for organisation attempt to delete a repository
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "repository" endpoint with the repository id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "repository" endpoint with the repository id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "organisation" of type "object"
        And response "data" should be an object with "created_by" of type "unicode"
        And response "data" should be an object with "service" of type "object"
        And response should not have key "errors"
