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


  Scenario Outline: 404 on invalid hubkeys
      Given a hub key "<hub_key>"

       When I make a "GET" request to the "resolve" endpoint with the unescaped id_map hub_key

       Then I should receive a "404" response code

       Examples:
            | hub_key                                              |
            | s0/hub1/asset/maryevans/432432423                    |
            | s1/hub1/423423423/asset/azfsdf                       |
            | s1/hub1/423423423/asset                              |
