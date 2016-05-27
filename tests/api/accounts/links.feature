# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Ability to set redirect URIs in organisations

  Background: the "accounts" service
      Given the "accounts" service
        And the existing user "harry"
        And the user is logged in
        And the existing organisation "toppco"

  Scenario: List reference links associated with an unknown id_type
      Given parameter "source_id" is a unique string
        And parameter "source_id_type" is "unknowndemoidtype"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"


       When I make a "POST" request to the "links" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" is an empty array

  Scenario: List organisation with reference link for id_type
      Given parameter "source_id" is a unique string
        And parameter "source_id_type" is "demoidtype"
        And Header "Authorization" is a valid token
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the organisation reference link for "demoidtype" has been set to "http://www.toppco.com/"

       When I make a "POST" request to the "links" endpoint

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
        And response "data" is a non empty array
        And response "data" should be an array of type "dictionary" with keys "organisation_id link"
