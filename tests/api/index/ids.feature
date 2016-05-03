# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Return related ids on single and bulk queries

  Background:
      Given the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the "hogwarts" "index" service

  Scenario Outline: Retrieve relations of an entity in the index
      Given a "valid" offer
        And related asset have been added for the given offer
        And the "index" service
        And we wait 15 seconds
        And the "<entity-repositories>" endpoint
        And Header "Accept" is "application/json"
        And parameter "related_depth" is "2"

       When I make a "GET" request with the id_map <id>

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "repositories"
        And each element of "data/repositories" has attributes "repository_id,entity_id"
        And response "data" should be a "dictionary" with key "relations"
        And each element of "data/relations" has attributes "via/source_id,via/source_id_type,via/entity_id"
        And each element of "data/relations" has attributes "to/repository_id,to/entity_id"
        And response should not have key "errors"

    Examples:
    | entity-repositories                                                        | id   |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | S1   |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | S2   |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | S3   |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | S5   |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | HK1  |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | HK2  |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | HK3  |
    | /entity-types/asset/id-types/{}/ids/{}/repositories                        | HK4  |
