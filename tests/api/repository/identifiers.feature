# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The Identifiers endpoint

  Background:
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the repository

      Given the "identifiers" endpoint for the repository


  Scenario: successfully query for identifiers on a small time range
      Given Header "Accept" is "application/json"
       And parameter "from" is "2015-12-31"
       And parameter "to" is "2016-01-01"
       And parameter "page" is "1"
       And parameter "page_size" is "5"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response should have key "data"
        And response should have key "metadata"



  Scenario: invalid date when querying the identifiers endpoints
      Given Header "Accept" is "application/json"
       And parameter "from" is "fadsfadsf"
       And parameter "to" is "2016-01-01"
       And parameter "page" is "1"
       And parameter "page_size" is "5"

       When I make a "GET" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "errors"


  Scenario: fail when page size is too large
      Given Header "Accept" is "application/json"
       And parameter "from" is "2015-01-01"
       And parameter "to" is "2016-01-01"
       And parameter "page" is "1"
       And parameter "page_size" is "2000000"

       When I make a "GET" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "errors"


  Scenario: fail when page is less than 1
      Given Header "Accept" is "application/json"
       And parameter "from" is "2015-01-01"
       And parameter "to" is "2016-01-01"
       And parameter "page" is "0"
       And parameter "page_size" is "5"

       When I make a "GET" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have key "errors"

