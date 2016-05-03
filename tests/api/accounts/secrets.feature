# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Service Client Secrets endpoint

  Background: a logged in user, with an organisation & service
      Given the "accounts" service
        And the existing user "cathy"
        And the user is logged in
        And the existing organisation "testco"
        And the organisation has an "external" service
        And the service has a client secret


  Scenario: Global admin get client secrets for a service
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "string"
        And response should not have key "errors"


  Scenario: Org user get client secrets for a service
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an array of type "string"
        And response should not have key "errors"


  Scenario: Get client secrets for unapproved service
      Given the existing user "katie"
        And the user is logged in
        And the organisation has a "repository" service
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Get client secrets for a service when unauthenticated
      Given Header "Accept" is "application/json"

       When I make a "GET" request to the "secrets" endpoint with the service id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation get client secrets
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Org admin create a client secret
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "string"
        And response should not have key "errors"


  Scenario: Global admin create a client secret
      Given the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "string"
        And response should not have key "errors"


  Scenario: Service owner create a client secret
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "string"
        And response should not have key "errors"


  Scenario: Create a client secret for unapproved service
      Given the existing user "katie"
        And the user is logged in
        And the organisation has a "repository" service
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Create a client secret when unauthenticated
      Given Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation attempt to create client secret
      Given the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not admin of organisation attempt to create client secret
      Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "POST" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Org Admin delete all client secrets for a service
      Given the service has a client secret
        And the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Global Admin delete all client secrets for a service
      Given the service has a client secret
        And the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Service owner delete all client secrets for a service
     Given the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And the service has a client secret
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Unauthenticated delete all client secrets request
      Given the service has a client secret
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation attempt to delete all client secrets
      Given the service has a client secret
        And the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not admin for organisation attempt to delete all client secrets
      Given the service has a client secret
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secrets" endpoint with the service id

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: Org Admin delete given client secret for a service
      Given the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And the service has a client secret
        And the user is logged in
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Global Admin delete given client secret for a service
      Given the service has a client secret
        And the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Service owner delete given client secret for a service
     Given the service has a client secret
        And the existing user "cathy"
        And the user is logged in
        And Header "Authorization" is a valid token
        And the organisation has an "external" service
        And the service has a client secret
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "message"
        And response should not have key "errors"


  Scenario: Unauthenticated delete given client secret request
      Given the service has a client secret
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "401" response code
        And response should have key "status" of 401
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not part of organisation attempt to delete given client secret
      Given the service has a client secret
        And the existing user "harry"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"


  Scenario: User not admin for organisation attempt to delete given client secret
      Given the service has a client secret
        And the existing user "katie"
        And the user is logged in
        And Header "Authorization" is a valid token
        And Header "Accept" is "application/json"

       When I make a "DELETE" request to the "secret" endpoint with service id & secret

       Then I should receive a "403" response code
        And response should have key "status" of 403
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
        And the errors should contain an object with "source" of "accounts"
