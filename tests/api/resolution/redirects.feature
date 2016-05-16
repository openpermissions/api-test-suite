# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: The resolution service redirects when needed to target website

  Background: the "resolution" service.
      Given the "resolution" service
        And the existing user "harry"
        And the user is logged in
        And the existing organisation "toppco"


  Scenario: resolve correctly asset with a valid hk0
      Given a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map hub_key0

       Then I should receive a "200" response code

  Scenario: resolve correctly asset with a valid hk1
      Given a "valid" offer
        And an asset has been added for the given offer
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map hub_key1

       Then I should receive a "200" response code

  Scenario: resolve correctly asset with a hk0 with an associated registered idtype
      Given a "valid" offer
        And an asset has been added for the given offer
        And the additional id "demoidtype" "0123456789" has been attached to the asset
        And the asset has been indexed
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the "toppco" reference link for "demoidtype" has been set to "http://www.toppco.com/"
        And the "testco/cathy" reference link for "demoidtype" has been set to "http://www.testco.com/"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map hub_key0

       Then I should receive a "302" response code

  Scenario: resolve correctly asset with a hk1 with an associated registered idtype
      Given a "valid" offer
        And an asset has been added for the given offer
        And the additional id "demoidtype" "0123456789" has been attached to the asset
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the "toppco" reference link for "demoidtype" has been set to "http://www.toppco.com/"
        And the "testco/cathy" reference link for "demoidtype" has been set to "http://www.testco.com/"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map hub_key1

       Then I should receive a "302" response code
