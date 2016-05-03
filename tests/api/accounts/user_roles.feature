# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The User Roles endpoint with the user id

  Background: the "user roles" service
      Given the "accounts" service


  Scenario: Get all organisation-roles for a user
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "user roles" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "organisation_id role"
        And response should not have key "errors"


  Scenario: Get organisation-roles with invalid user ID
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "user roles" endpoint with "invalid_user_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get organisation-roles with Missing user ID
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "user roles" endpoint

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And parameter "role_id" is "user"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And a "data" object with "id" of user id
        And a "data" object with "email" of user email
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"


  Scenario: Update Global Role for a user with invalid role id
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And parameter "role_id" is "invalid_role_id"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user with no data
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user with incorrect parameters
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "harry"
        And parameter "foo" is "bar"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for an invalid user
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "role_id" is "user"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with "invalid_user_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a missing user
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "role_id" is "user"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user without authentication
      Given the existing user "harry"
        And parameter "role_id" is "user"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user without authentication and with invalid parameters
      Given the existing user "harry"
        And parameter "role_id" is "invalid_role_id"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user with invalid role authorization
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "katie"
        And parameter "role_id" is "user"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update Global Role for a user with invalid role authorization and invalid parameters
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the existing user "katie"
        And parameter "role_id" is "invalid_role_id"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "user roles" endpoint with the user id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
