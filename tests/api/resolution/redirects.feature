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



# /s0/hub1/asset/testco/demoidtype/unknownid
# /s1/hub1/{repo_id}/asset/f7777573033111e6b459acbc32a8c615

  Scenario: resolve correctly asset with a valid hk0
        Given a "valid" offer
        And an asset has been added for the given offer
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

        When I make a "GET" request to the "resolv" endpoint with the unescaped id_map hub_key0

        Then I should receive a "200" response code

#REPLY_BODY_JSON = {
#    "organisation_id": "testco",
#    "entity_id": "f38a57a0f23a485da0853230d8c212dc",
#    "entity_type": "asset",
#    "hub_id": "hub1",
#    "hub_key": "https://resolution:8009/s0/hub1/asset/testco/testcopictureid/f38a57a0f23a485da0853230d8c212dc",
#    "schema_version": "s0",
#    "id_type": "testcopictureid",
#    "provider": {
#        "website": "http://testco.digicat.io",
#        "star_rating": 0,
#        "name": "TestCo",
#        "twitter": "DigiCatapult",
#        "created_by": "testadmin",
#        "id": "testco",
#        "phone": "0300 1233 101",
#        "state": "approved",
#        "address": "Digital Catapult\n101 Euston Road London\nNW1 2RA",
#        "email": "exampleco@digicat.io",
#        "description": "A fictional company for testing purposes"
#    },
#    "resolver_id": "https://resolution:8009"
#}


  Scenario: resolve correctly asset with a valid hk1
        Given a "valid" offer
        And an asset has been added for the given offer
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"

        When I make a "GET" request to the "resolv" endpoint with the unescaped id_map hub_key1

        Then I should receive a "200" response code

# REPLY_BODY_JSON = {
#    "repository_id": "0f9d91051b69462892630f080db18d6d",
#    "entity_id": "4089330afee8404eb09b08d72ae9a25a",
#    "entity_type": "asset",
#    "hub_id": "hub1",
#    "hub_key": "https://resolution:8009/s1/hub1/0f9d91051b69462892630f080db18d6d/asset/4089330afee8404eb09b08d72ae9a25a",
#    "schema_version": "s1",
#    "provider": {
#        "website": "http://testco.digicat.io",
#        "star_rating": 0,
#        "name": "TestCo",
#        "twitter": "DigiCatapult",
#        "created_by": "testadmin",
#        "id": "testco",
#        "phone": "0300 1233 101",
#        "state": "approved",
#        "address": "Digital Catapult\n101 Euston Road London\nNW1 2RA",
#        "email": "exampleco@digicat.io",
#        "description": "A fictional company for testing purposes"
#    },
#    "resolver_id": "https://resolution:8009"
#}


  Scenario: resolve correctly asset with a hk0 to registered idtype

        Given  Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And a hubkey s0 "s0/hub1/asset/testco/demoidtype/idIDidID1d"
        And the "toppco" reference link for "demoidtype" has been set to "http://www.toppco.com/"
        And the "testco/cathy" reference link for "demoidtype" has been set to "http://www.testco.com/"
        When I make a "GET" request to the "resolv" endpoint with the unescaped id_map hub_key0

        Then I should receive a "301" response code


  Scenario: resolve correctly asset with a hk1 with an associated registered idtype
        Given a "valid" offer
        And an asset has been added for the given offer
        And the additional id "demoidtype" "0123456789" has been attached to the asset
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the "toppco" reference link for "demoidtype" has been set to "http://www.toppco.com/"
        And the "testco/cathy" reference link for "demoidtype" has been set to "http://www.testco.com/"
        When I make a "GET" request to the "resolv" endpoint with the unescaped id_map hub_key1

        Then I should receive a "301" response code

