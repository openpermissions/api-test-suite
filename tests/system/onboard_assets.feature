# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Asset Onboarding
  Background:
      Given the default repository is created
        And I am using a "testco" client


  Scenario Outline: Onboard an Asset with Offers and then Query the Asset
      Given "3" offers have already been onboarded
        And I onboard an asset in "<format>" format for the offers
        And the asset has been indexed

       When I query for the offers for the asset

       Then I will receive the 3 offers

    Examples:
        | format |
        | json   |
        | csv    |


  Scenario: Query for Licensors of an Asset
      Given "1" offers have already been onboarded
        And I onboard an asset that has a licensor
        And the asset has been indexed

       When I query for the licensor for that asset

       Then I will receive that licensor
