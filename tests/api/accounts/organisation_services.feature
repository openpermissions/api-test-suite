# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Organisation Services endpoint

  Background: the "accounts" service
      Given the "accounts" service
        And the existing user "harry"
        And the user is logged in
        And the existing organisation "toppco"


  Scenario: Create and add a service to an organisation
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "external"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: Create a service with permissions and add to an organisation
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "external"
        And parameter "permissions" is a valid set of service permissions
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"

    Scenario: Create and add a service to an organisation as global admin
      Given the existing user "testadmin"
        And the user is logged in
        And parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "external"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


    Scenario: Create and add a service to an organisation with missing name parameter
      Given parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


    Scenario: Create and add a service to an organisation with missing location parameter
      Given parameter "name" is a unique string
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


    Scenario: Create and add a service to an organisation with missing service_type parameter
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


    Scenario: Create and add a service to an organisation with invalid service_type parameter
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "an invalid service type"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


    Scenario: Create and add a service to an organisation with invalid location
      Given parameter "name" is a unique string
        And parameter "location" is "an.invalid.location"
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Create and add a service to an organisation with invalid permissions
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And parameter "permissions" is "an invalid set of service permissions"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


    Scenario: Create and add a service to an organisation where location already exists
      Given the organisation has an "external" service
        And parameter "name" is a unique string
        And parameter "location" is the service location
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Create a service with name already exists
      Given the organisation has an "external" service
        And parameter "name" is the service name
        And parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Create a service with invalid organisation ID
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with "an_invalid_org_id"

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthenticated request to create a service
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Invalid authorization for service asset
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "repository"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Invalid request for service asset with invalid authorization
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "service_type" is "repository"
        And parameter "name" is a unique string
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Request create service with missing Content-Type and Accept - JSON is assumed
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And parameter "service_type" is "external"
        And Header "Authorization" is a valid token

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: Request create service with incorrect Content-Type
      Given parameter "name" is a unique string
        And parameter "location" is a unique string
        And parameter "service_type" is "repository"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "not an acceptable content type"
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "organisation services" endpoint with the organisation id

       Then I should receive a "415" response code
        And response should have key "status" of 415
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

