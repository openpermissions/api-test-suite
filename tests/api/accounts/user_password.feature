# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Users Password endpoint with the user id

  Background: the "user password" service
      Given the "accounts" service
        And the existing user "harry"
        And the user is logged in
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

  Scenario: Update password for user
      Given a new user
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "previous" is the user password
        And parameter "password" is a unique string

       When I make a "PUT" request to the "user password" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Unauthenticated update password for user
      Given parameter "previous" is the user password
        And parameter "password" is a unique string

       When I make a "PUT" request to the "user password" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update password for missing user
      Given Header "Authorization" is a valid token
        And parameter "previous" is the user password
        And parameter "password" is a unique string

       When I make a "PUT" request to the "user password" endpoint with "invalid_user_id"

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update password for user wrong previous password
      Given Header "Authorization" is a valid token
        And parameter "previous" is "invalid_previous_password"
        And parameter "password" is a unique string

       When I make a "PUT" request to the "user password" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update password invalid new password
      Given Header "Authorization" is a valid token
        And parameter "previous" is the user password
        And parameter "password" is "a"

       When I make a "PUT" request to the "user password" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Update password missing parameter
      Given Header "Authorization" is a valid token
        And parameter "<parameter>" is <value>

       When I make a "PUT" request to the "user password" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | parameter | value             |
            | previous  | the user password |
            | password  | a unique string   |
