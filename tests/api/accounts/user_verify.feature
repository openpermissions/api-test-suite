# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Users Verify endpoint with the user id

  Background: the "user verify" service
      Given the "accounts" service
        And a new user

      @notimplemented
  Scenario: Verify user
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "verification_hash" is the user verification_hash
       When I make a "PUT" request to the "user verify" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of value True
        And response "data" should be an object without "password"
        And response should not have key "errors"

      @notimplemented
  Scenario: Verify user that is already verified
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "verification_hash" is the user verification_hash
       When I make a "PUT" request to the "user verify" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"

       When I make a "PUT" request to the "user verify" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "verified" of value True
        And response "data" should be an object without "password"
        And response should not have key "errors"


  Scenario: Verify user no parameter
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "user verify" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Verify user invalid parameter
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "invalid_parameter" is a unique string

       When I make a "PUT" request to the "user verify" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
