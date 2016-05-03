# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Users endpoint

  Background: the "users" service
      Given the "accounts" service


  Scenario: Create a user
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of value False
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response should not have key "errors"


  Scenario: Create a user who does not agree to terms and conditions
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "false"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
        And the errors should contain an object with "field" of "has_agreed_to_terms"


  Scenario Outline: Create a user, with optional parameters
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And parameter "<parameter>" is "<value>"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of value False
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response "data" should be an object with "<parameter>" of value "<value>"
        And response should not have key "errors"

        Examples:
            | parameter  | value  |
            | first_name | Eddard |
            | last_name  | Stark  |
            | phone      | raven  |


  Scenario: Create user, with unexpected parameter
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And parameter "foo" is "bar"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Create a user, with an invalid organisation ID
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And parameter "organisation_id" is "an_invalid_org_id"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Missing parameter
      Given parameter "<parameter>" is <value>
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "2" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


        Examples:
            | parameter           | value                  |
            | email               | a unique email address |
            | password            | "password"             |
            | has_agreed_to_terms | boolean "true"         |


  Scenario: Create a duplicate user
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: missing Content-Type and Accept - JSON is assumed
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of value False
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response should not have key "errors"


  Scenario: Incorrect Content-Type
      Given parameter "email" is a unique email address
        And parameter "password" is "password"
        And parameter "has_agreed_to_terms" is boolean "true"
        And Header "Content-Type" is "not an acceptable content type"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "users" endpoint

       Then I should receive a "415" response code
        And response should have key "status" of 415
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get a user
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of type "bool"
        And response "data" should be an object without "password"
        And response "data" should be an object without "verification_hash"
        And response should not have key "errors"


  Scenario: Get a user with an ID for another type of resource
      Given the existing user "harry"
        And the existing organisation "hogwarts"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "user" endpoint with the organisation id

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get all users
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "id email"
        And response should not have key "errors"


  @notimplemented
  Scenario: Get all users when there are none
      Given Header "Accept" is "application/json"

       When I make a "GET" request to the "users" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "0"
        And response should not have key "errors"


  Scenario Outline: Update a user
      Given a new user
        And the user is logged in
        And parameter "first_name" is <first_name>
        And parameter "last_name" is <last_name>
        And parameter "email" is <email>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "user" endpoint with the user id

       Then response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "first_name" same as the submitted value
        And response "data" should be an object with "last_name" same as the submitted value
        And response "data" should be an object with "email" same as the submitted value
        And response "data" should be an object with "verified" of type "bool"

        Examples:
            | first_name          | last_name          | email                  |
            | a unique string     | a unique string    | a unique email address |
            | the user first_name | the user last_name | the user email         |
            | a unique string     | a unique string    | the user email         |


  Scenario: Update a user with invalid parameter
      Given a new user
        And the user is logged in
        And parameter "first_name" is a unique string
        And parameter "last_name" is a unique string
        And parameter "email" is a unique email address
        And parameter "invalid_param" is "invalid value"
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "user" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update non-required parameter of user
      Given the existing user "harry"
        And parameter "last_name" is a unique string
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "first_name" of type "unicode"
        And response "data" should be an object with "last_name" same as the submitted value
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of type "bool"


  Scenario: Update a user with an email that already exists
      Given the existing user "harry"
        And parameter "email" is the user email
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "user" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Delete a user
      Given a new user
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "user" endpoint with the user id

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Delete a user with an organisation
      Given a new user
        And the user is logged in
        And the existing organisation "hogwarts"
        And the user has joined the organisation
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"


  Scenario: Unauthorized delete a user
      Given a new user

       When I make a "DELETE" request to the "user" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Given the user is logged in
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"


  Scenario: Delete a user that doesn't exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "user" endpoint with "an_invalid_user_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
