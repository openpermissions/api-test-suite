# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Organisations endpoint

  Background: the "accounts" service and harry the admin for hogwarts
      Given the "accounts" service
        And the existing user "harry"
        And the user is logged in
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"


  Scenario: Register a new organisation
      Given Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "email" is "organisation@example.com"
        And parameter "phone" is "020 1111 1111"
        And parameter "twitter" is "@organisation"

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "/data/id" should be of type "unicode"
        And response "/data/name" should be of type "unicode"
        And response "/data/email" should be of type "unicode"
        And response "/data/phone" should be of type "unicode"
        And response "/data/twitter" should be of type "unicode"
        And response "/data/state" should be "pending"
        And response "/data/star_rating" should be integer "0"
        And response should not have key "errors"

  Scenario: Admin register a new organisation
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "email" is "organisation@example.com"
        And parameter "star_rating" is integer "4"

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "/data/state" should be "approved"
        And response "/data/star_rating" should be integer "4"
        And response should not have key "errors"


  Scenario: Organisation with the same name already exists
      Given the existing organisation "hogwarts"
        And parameter "name" is the organisation name
        And Header "Authorization" is a valid token

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Register a new organisation with invalid field
      Given Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "invalid_field" is "invalid field"

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Register a valid organisation with insuffication authentication
      Given parameter "name" is a unique string

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Register an invalid organisation with insufficient authentication
      Given parameter "name" is a unique string
        And parameter "invalid_field" is "invalid field"

       When I make a "POST" request to the "organisations" endpoint

       Then I should receive a "401" response code
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get organisation
      Given the existing organisation "hogwarts"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "state" of type "unicode"
        And response should not have key "errors"


  Scenario: Get invalid organisation
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "organisation" endpoint with "an_invalid_org_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get all organisations
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "organisations" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "id name state"
        And response should not have key "errors"


  Scenario: Get all organisations with query param
      Given a new organisation
        And parameter "state" is "pending"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "organisations" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "id name state"
        And response should not have key "errors"


  Scenario: Get all organisations with invalid query param
      Given parameter "state" is "foo"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "organisations" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Organisation creator update a pending organisation by changing valid param
      Given a new organisation
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "state" of value "pending"
        And response should not have key "errors"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |


  Scenario Outline: Organisation creator update a pending organisation by changing invalid param
      Given a new organisation
        And parameter "<parameter>" is "<value>"
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                  |
            | state      | rejected               |
            | state      | approved               |


  Scenario Outline: Unauthorised user update a pending organisation changing param
      Given a new organisation
        And the existing user "katie"
        And the user is logged in
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |
            | state      | "approved"                 |


  Scenario Outline: Unauthenticated user update a pending organisation changing param
      Given a new organisation
        And the existing user "katie"
        And the user is logged in
        And parameter "<parameter>" is <value>

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |
            | state      | "approved"                 |


  Scenario Outline: Global admin update a pending organisation changing param
      Given a new organisation
        And the existing user "testadmin"
        And the user is logged in
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "state" of type "unicode"
        And response should not have key "errors"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |
            | state      | "approved"                 |


  Scenario: Global admin update a pending organisation with invalid state param
      Given a new organisation
        And the existing user "testadmin"
        And the user is logged in
        And parameter "state" is "foo"
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Organisation admin update an approved organisation by changing param
      Given the existing organisation "hogwarts"
        And the existing user "harry"
        And the user is logged in
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "state" of type "unicode"
        And response should not have key "errors"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |


  Scenario Outline: Global admin update an approved organisation by changing param
      Given the existing organisation "hogwarts"
        And the existing user "testadmin"
        And the user is logged in
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "/data/id" should be of type "unicode"
        And response "/data/name" should be of type "unicode"
        And response "/data/state" should be "approved"
        And response should not have key "errors"

        Examples:
            | parameter   | value                      |
            | name        | a unique string            |
            | name        | the organisation name      |
            | email       | "organisation@example.com" |
            | star_rating | integer "5"                |


  Scenario Outline: Unauthorised user update an approved organisation by changing param
      Given the existing organisation "testco"
        And the existing user "katie"
        And parameter "<parameter>" is <value>
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |
            | state      | "pending"                  |


  Scenario Outline: Unauthenticated user update an approved organisation by changing param
      Given the existing organisation "testco"
        And the existing user "katie"
        And parameter "<parameter>" is <value>

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter  | value                      |
            | name       | a unique string            |
            | name       | the organisation name      |
            | email      | "organisation@example.com" |
            | state      | "pending"                  |


  Scenario: Update an organisation with a name that already exists
      Given the existing user "testadmin"
        And the user is logged in
        And the existing organisation "hogwarts"
        And parameter "name" is the organisation name
        And the existing organisation "testco"
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Put invalid organisation
      Given the existing user "testadmin"
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string

       When I make a "PUT" request to the "organisation" endpoint with "an_invalid_org_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthenticated PUT
      Given the existing organisation "hogwarts"
        And parameter "name" is a unique string

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Organisation Admin delete an organisation
      Given the existing user "testadmin"
        And a new organisation
        And the existing user "harry"
        And the user has role "administrator" for the organisation
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object without the organisation id
        And response should not have key "errors"


  Scenario: Global admin Delete an organisation
      Given the existing user "testadmin"
        And the user is logged in
        And a new organisation
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "user" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should contain an "organisations" object without the organisation id
        And response should not have key "errors"


  Scenario: Unauthorised user delete an organisation
      Given the existing organisation "testco"
        And the existing user "katie"
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "organisation" endpoint with the organisation id

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


  Scenario: Unauthenticated user delete an organisation
      Given the existing organisation "testco"
        And the existing user "katie"

       When I make a "DELETE" request to the "organisation" endpoint with the organisation id

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


  Scenario: Delete an organisation with a service
      Given the existing user "testadmin"
        And the user is logged in
        And a new organisation
        And the organisation has a "repository" service
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"

      Given parameter "organisation_id" is the organisation id
       When I make a "GET" request to the "services" endpoint

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Delete an organisation that doesn't exist
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "organisation" endpoint with "an_invalid_org_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Global admin should be able to update an organisation's start rating
      Given a new organisation
        And the existing user "testadmin"
        And the user is logged in
        And parameter "star_rating" is integer "<star_rating>"
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response "/data/star_rating" should be integer "<star_rating>"

        Examples:
        | star_rating |
        | 0           |
        | 1           |
        | 2           |
        | 3           |
        | 4           |
        | 5           |


  Scenario: Organisation admin should not be able to change start rating
      Given a new organisation
        And Header "Authorization" is a valid token
        And parameter "star_rating" is integer "3"

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "403" response code
        And response "/errors/0/message" should be "User cannot update field 'star_rating'"
