# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Login endpoint

  Background: the "accounts" service
      Given the "accounts" service
        And the existing user "harry"


  Scenario: Login with a valid email and password
      Given parameter "email" is the user email
        And parameter "password" is the user password
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "token" of type "unicode"
        And response "data" should contain a "user" object with "id" of type "unicode"
        And response "data" should contain a "user" object with "email" of type "unicode"
        And response "data" should contain a "user" object with "verified" of type "bool"
        And response "data" should contain a "user" object without "password"
        And response "data" should contain a "user" object without "verification_hash"
        And response should not have key "errors"


  Scenario Outline: Invalid credentials
      Given parameter "email" is <email>
        And parameter "password" is <password>
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

        Examples:
            | email               | password          |
            | the user email      | "wrong_password"  |
            | "not_a_valid_email" | the user password |
            | "admin2@example.com"   | the user password |


  Scenario: Missing email
      Given parameter "password" is "password"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Missing password
      Given parameter "email" is "admin@example.com"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: missing Content-Type and Accept - JSON is assumed
      Given parameter "email" is the user email
        And parameter "password" is the user password

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "token" of type "unicode"
        And response should not have key "errors"


  Scenario: Incorrect Content-Type
      Given parameter "email" is the user email
        And parameter "password" is the user password
        And Header "Content-Type" is "not an acceptable content type"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "login" endpoint

       Then I should receive a "415" response code
        And response should have key "status" of 415
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
