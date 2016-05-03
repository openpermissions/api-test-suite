# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The entities endpoint

  Background: the "query" service
      Given the "query" service
        And Header "Accept" is "application/json"

  Scenario: Get an agreement
      Given an agreement
        And the agreement's hub key is the "hub_key" parameter

       When I make a "GET" request to the "entities" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" should be an object with "@context"
        And response "data" should be an object with "@graph"

  Scenario: Get an agreement via entity id
      Given an agreement
        And the entities endpoint of the query service for the current agreement

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" should be an object with "@context"
        And response "data" should be an object with "@graph"

  Scenario: Get an offer via entity id
      Given a "valid" offer
        And the entities endpoint of the query service for the current offer

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" should be an object with "@context"
        And response "data" should be an object with "@graph"

  Scenario: Fail to get an agreement via entity id
      Given an invalid reference to an agreement
        And the entities endpoint of the query service for the current agreement

       When I make a "GET" request

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"


  Scenario: Get an offer with the wrong id
      Given parameter "hub_key" is a hub key that does not exist

       When I make a "GET" request to the "entities" endpoint

       Then I should receive a "404" response code
        And response should have key "status" of 404
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "1" with keys "source message"
