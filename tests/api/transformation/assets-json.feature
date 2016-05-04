# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Assets endpoint handles JSON

  Background:
      Given the "transformation" service
        And the "assets" endpoint
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the "toppco" "transformation" service
        And Header "Content-Type" is "application/json; charset=utf-8"


  Scenario: transform well formed JSON data
      Given request body is the content of file "transformation/valid_json.json"
       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "rdf_n3"
        And response should not have key "errors"


  Scenario: transform well formed JSON data with custom karma mapping url
      Given request body is the content of file "transformation/valid_json.json"
        And the endpoint has a valid "json" r2rml_url query parameter

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "rdf_n3"
        And response should not have key "errors"

  @notimplemented
  Scenario: transform JSON data with missing keys
      Given request body is the content of file "transformation/invalid_json.json"

       When I make a "POST" request

       Then I should receive a "400" response code
        And response should have key "status" of 400
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should have array "errors" of size "2" with keys "source message asset"
        And the errors should contain an object with "source" of "transformation"
