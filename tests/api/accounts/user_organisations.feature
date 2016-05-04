# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Users Organisations endpoint with the user id

  Background: the "user organisations" endpoint
      Given the "accounts" service
        And the existing user "katie"
        And the user is logged in
        And the existing organisation "testco"
        And Header "Accept" is "application/json"


  Scenario: Get organisations for a user
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisations" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "id name state"
        And response should not have key "errors"


  Scenario: Get organisations for a user with query param
      Given parameter "state" is "approved"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisations" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "dictionary" with keys "id name state"
        And response should not have key "errors"


  Scenario: Get all organisations with invalid query param
      Given parameter "state" is "bar"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisations" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get organisations for user when there are none
      Given a new user
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisations" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "data" of size "0"
        And response should not have key "errors"


  Scenario: Get organisations for user when the user does not exist
      Given the user "id" is "invalid_user_id"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "user organisations" endpoint with user & organisation IDs

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Assign a user to an organisation
      Given a new user
        And parameter "organisation_id" is the organisation id
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"


  Scenario: Assign a user to an invalid organisation ID
      Given parameter "organisation_id" is "an_invalid_org_id"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Assign a user to organisation that is not approved
      Given a new organisation
        And parameter "organisation_id" is the organisation id
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Missing organisation ID
      Given Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Assign a user to an organisation with invalid authentication
      Given parameter "organisation_id" is the organisation id
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Missing organisation ID and invalid authentication
      Given Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: missing Content-Type and Accept - JSON is assumed
      Given a new user
        And parameter "organisation_id" is the organisation id
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "email" of type "unicode"
        And response "data" should be an object with "organisations" of type "dictionary"
        And response should not have key "errors"


  Scenario: Incorrect Content-Type
      Given a new user
        And parameter "organisation_id" is the organisation id
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "not an acceptable content type"

       When I make a "POST" request to the "user organisations" endpoint with the user id

       Then I should receive a "415" response code
        And response should have key "status" of 415
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
