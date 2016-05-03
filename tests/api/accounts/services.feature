# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Services endpoint

  Background: the "accounts" service
      Given the "accounts" service
        And the existing user "cathy"
        And the user is logged in
        And the existing organisation "testco"
        And the organisation has an "external" service


  Scenario: Get services
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "services" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"


  Scenario: Get services for an organisation
      Given parameter "organisation_id" is the organisation id
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "services" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And array "data" should contain the organisation service
        And response should not have key "errors"


  Scenario: Get services filtered by type
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "type" is "external"

       When I make a "GET" request to the "services" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: Get services filtered by type and organisation
      Given Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And parameter "type" is "external"
        And parameter "organisation_id" is the organisation id

       When I make a "GET" request to the "services" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" is a non empty array
        And response should not have key "errors"


  Scenario: Get services for an organisation that does not exist
      Given parameter "organisation_id" is "not a real organisation"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "services" endpoint

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

  Scenario: Get a service by id
      Given Header "Accept" is "application/json"
        And Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: Get a service with an ID for another type of resource
      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the organisation id

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario Outline: Org admin update service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has a "repository" service
        And the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "<param>" is <value>
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"

        Examples:
        | param        | value                              |
        | name         | a unique string                    |
        | location     | a unique location                  |
        | permissions  | a valid set of service permissions |


  Scenario Outline: Global admin update service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "<param>" is <value>

        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"

        Examples:
            | param        | value                              |
            | name         | a unique string                    |
            | location     | a unique location                  |
            | service_type | "index"                            |
            | permissions  | a valid set of service permissions |


  Scenario Outline: Service owner admin update service
      Given Header "Authorization" is a valid token
        And parameter "<param>" is <value>
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"

        Examples:
            | param        | value                              |
            | name         | a unique string                    |
            | location     | a unique location                  |
            | permissions  | a valid set of service permissions |



  Scenario Outline: A user who is not an admin update service type
      Given the existing user "<user>"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has a "repository" service
        And parameter "service_type" is "index"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message field"
        And the errors should contain an object with "source" of "accounts"

        Examples:
          | user  |
          | katie |
          | cathy |


  Scenario Outline: A user who is not an admin update service state
      Given the existing user "<user>"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has a "repository" service
        And parameter "state" is "approved"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message field"
        And the errors should contain an object with "source" of "accounts"

        Examples:
          | user  |
          | katie |
          | cathy |


  Scenario Outline: Update service with invalid value
      Given parameter "<param>" is <value>
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

    Examples:
            | param        | value                         |
            | location     | "an.invalid.location"         |
            | permissions  | "invalid.service.permissions" |


  Scenario: Update service where location already exists
      Given parameter "location" is the service location
        And the organisation has a "repository" service
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update organisation id of service
      Given parameter "organisation_id" is "an_org_id"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Update invalid key of service
      Given parameter "foo" is "bar"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthenticated update of service
      Given parameter "name" is a unique string
        And parameter "location" is a unique location
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation attempt to update service
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "location" is a unique location
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not admin for organisation attempt to update service
      Given the organisation has an "external" service
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And parameter "location" is a unique location
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Invalid request to update service with invalid authorization
      Given the organisation has an "external" service
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "organisation_id" is "an_invalid_org_id"
        And parameter "name" is a unique string
        And parameter "location" is a unique location
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "PUT" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Org Admin Delete a service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has a "repository" service
        And the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "service" endpoint with the service id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "service" endpoint with the service id
       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Global Admin Delete a service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has a "repository" service

       When I make a "DELETE" request to the "service" endpoint with the service id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "service" endpoint with the service id
       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Service owner Delete a service
      Given the organisation has a "repository" service
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "service" endpoint with the service id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "data"
        And response should not have key "errors"

       When I make a "GET" request to the "service" endpoint with the service id
       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Delete a service that doesn't exist
      Given Header "Authorization" is a valid token

       When I make a "DELETE" request to the "service" endpoint with "an_invalid_service_id"

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Unauthorized delete a service
       When I make a "DELETE" request to the "service" endpoint with the service id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

      Given Header "Authorization" is a valid token

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "service_type" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


  Scenario: User not part of organisation attempt to delete a service
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "service" endpoint with the service id
       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response should not have key "errors"


  Scenario: User not admin for organisation attempt to delete a service
      Given the organisation has an "external" service
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token

       When I make a "DELETE" request to the "service" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"

       When I make a "GET" request to the "service" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "location" of type "unicode"
        And response "data" should be an object with "organisation_id" of type "unicode"
        And response "data" should be an object with "permissions" of type "list"
        And response should not have key "errors"


   Scenario: Get service types
        When I make a "GET" request to the "service types" endpoint

        Then I should receive a "200" response code
         And response should have key "status" of 200
         And response header "Content-Type" should be "application/json; charset=UTF-8"
         And response "data" is a non empty array


  Scenario: Approve a Service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "state" is "approved"

      When I make a "PUT" request to the "service" endpoint with the service id

      Then I should receive a "200" response code
       And response should have key "status" of 200
       And response header "Content-Type" should be "application/json; charset=UTF-8"
       And response "data" should be an object with "id" of type "unicode"
       And response "data" should be an object with "name" of type "unicode"
       And response "data" should be an object with "location" of type "unicode"
       And response "data" should be an object with "organisation_id" of type "unicode"
       And response "data" should be an object with "permissions" of type "list"
       And response should not have key "errors"
