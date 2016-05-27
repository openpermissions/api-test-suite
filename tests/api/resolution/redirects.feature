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
        And the existing user "cathy"
        And the user is logged in
        And the existing organisation "testco"

        And a "valid" offer
        And an asset has been added for the given offer
        And the asset has been indexed

        And Header "Content-Type" is "application/json"

  Scenario Outline: resolve json correctly
      Given the organisation has no reference links
        And Header "Accept" is "application/json"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map <hub_key>
       Then I should receive a "200" response code
    Examples:
      | hub_key  |
      | hub_key0 |
      | hub_key1 |

  Scenario Outline: resolve html correctly
      Given the organisation has no reference links

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map <hub_key>
       Then I should receive a "200" response code
    Examples:
      | hub_key  |
      | hub_key0 |
      | hub_key1 |

  Scenario Outline: redirect correctly to redirect url without source id
      Given the organisation reference link and redirect for "testcopictureid" has been set to "http://www.example.com/"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map <hub_key>
       Then I should receive a "302" response code
    Examples:
      | hub_key  |
      | hub_key0 |
      | hub_key1 |


  Scenario Outline: redirect correctly to redirect url with source id
      Given the organisation reference link and redirect for "testcopictureid" has been set to "http://www.example.com/{source_id}"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map <hub_key>
       Then I should receive a "302" response code
    Examples:
      | hub_key  |
      | hub_key0 |
      | hub_key1 |


  Scenario Outline: redirect correctly to redirect url with an associated registered idtype
      Given the additional id "demoidtype" "0123456789" has been attached to the asset
        And the organisation reference link and redirect for "demoidtype" has been set to "http://www.example.com/{source_id}"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map <hub_key>
       Then I should receive a "302" response code
    Examples:
      | hub_key  |
      | hub_key0 |
      | hub_key1 |