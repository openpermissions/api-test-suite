# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Users Organisation endpoint with the user and organisation id

  Background: the "user organisation" endpoint
      Given the "accounts" service
        And the existing user "katie"
        And the user is logged in
        And the existing organisation "testco"
        And Header "Accept" is "application/json"


  Scenario: Get an organisation for a user
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "join_state" of type "unicode"
        And response should not have key "errors"


  Scenario: Get organisation for user when the organisation does not exist
      Given Header "Authorization" is a valid token
        And the organisation "id" is "invalid_organisation_id"

       When I make a "GET" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get organisation for user when the user does not exist
      Given Header "Authorization" is a valid token
        And the user "id" is "invalid_user_id"

       When I make a "GET" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get an organisation for a user when the user has not joined the organisation
      Given a new user
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Organisation admin update state of user-organisation association
      Given the existing organisation "hogwarts"
        And the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the user has requested to join the organisation
        And parameter "join_state" is "approved"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"

  Scenario: Organisation admin update role of a user for an organisation
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing organisation "hogwarts"
        And Header "Accept" is "application/json"
        And a new user
        And the user has joined the organisation

        And parameter "role_id" is "user"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And a "data" object with "id" of user id
        And a "data" object with "email" of user email
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"


  Scenario Outline: Organisation admin update invalid parameter of user-organisation association
      Given the existing organisation "hogwarts"
        And the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the user has joined the organisation
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                  |
            | join_state | invalid_state          |
            | role_id    | invalid_role           |
            | foo        | bar                    |


  Scenario: Global admin update state of user-organisation association
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the user has requested to join the organisation
        And parameter "join_state" is "approved"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"

  Scenario: Global admin update role of a user for an organisation
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"
        And a new user
        And the existing organisation "hogwarts"
        And the user has joined the organisation
        And parameter "role_id" is "user"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And a "data" object with "id" of user id
        And a "data" object with "email" of user email
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"

  Scenario Outline: Global admin update invalid parameter of user-organisation association
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the user has joined the organisation
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                  |
            | join_state | invalid_state          |
            | role_id    | invalid_role           |
            | foo        | bar                    |


  Scenario Outline: Update user when the organisation does not exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the organisation "id" is "invalid_organisation_id"
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Examples:
            | parameter  | value          |
            | join_state | approved       |
            | role_id    | user           |


  Scenario Outline: Update user when the user does not exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the user "id" is "invalid_user_id"
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Examples:
            | parameter  | value          |
            | join_state | approved       |
            | role_id    | user           |


  Scenario Outline: Update user when the user has not joined the organisation
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Examples:
            | parameter  | value          |
            | join_state | approved       |
            | role_id    | user           |


  Scenario: Set role for a user where join with organisation is not approved
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"
        And the existing organisation "hogwarts"
        And a new user
        And the user has requested to join the organisation
        And parameter "role_id" is "user"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Unauthorized update user for an organisation
      Given a new user
        And the user has requested to join the organisation
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value    |
            | join_state | approved |
            | role_id    | user     |
            | foo        | bar      |

  Scenario Outline: Unauthorized update user that does not belong to the organisation
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing organisation "testco"
        And the user is logged in
        And Header "Accept" is "application/json"
        And the existing user "harry"
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
        | parameter  | value    |
        | join_state | approved |
        | role_id    | user     |
        | foo        | bar      |

  Scenario Outline: Unauthenticated update user for an organisation
      Given the existing user "harry"
        And the existing organisation "hogwarts"
        And Header "Accept" is "application/json"
        And parameter "<parameter>" is "<value"
        And Header "Authorization" is " "

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

    Examples:
            | parameter  | value    |
            | join_state | approved |
            | role_id    | user     |
            | foo        | bar      |


  Scenario Outline: Unauthenticated update user that does not belong to the organisation
      Given the existing user "katie"
        And the existing organisation "testco"
        And the user is logged in
        And Header "Accept" is "application/json"
        And the existing user "harry"
        And parameter "<parameter>" is "<value>"

       When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
        | parameter  | value    |
        | join_state | approved |
        | role_id    | user     |
        | foo        | bar      |


  Scenario: Admin Disassociate a user and an organisation
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And a new user
        And the user has joined the organisation

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of type "bool"
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response should not have key "errors"

       When I make a "GET" request to the "user" endpoint with the user id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object without the organisation id
        And response should not have key "errors"

       When I make a "GET" request to the "organisation" endpoint with the organisation id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response should not have key "errors"


  Scenario: User disassociate themselves from an organisation
      Given a new user
        And the user is logged in
        And the user has joined the organisation
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of type "bool"
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response should not have key "errors"

       When I make a "GET" request to the "user" endpoint with the user id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object without the organisation id
        And response should not have key "errors"

       When I make a "GET" request to the "organisation" endpoint with the organisation id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response should not have key "errors"


  Scenario: Remove an organisation from a user who has not joined the organisation
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs
       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "organisation" endpoint with the organisation id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response should not have key "errors"


  Scenario: Unauthenticated disassociate user from an organisation
       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs
       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Given Header "Authorization" is a valid token
       When I make a "GET" request to the "user" endpoint with the user id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object with the organisation id
        And response should not have key "errors"


  Scenario: Unauthorized disassociate user from an organisation
      Given the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And the existing organisation "hogwarts"

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs
       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "user" endpoint with the user id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object with the organisation id
        And response should not have key "errors"


  Scenario: Remove organisation for a user that doesn't exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the user "id" is "invalid_user_id"

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Remove organisation from a user when the organisation doesn't exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation "id" is "invalid_organisation_id"

       When I make a "DELETE" request to the "user organisation" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

