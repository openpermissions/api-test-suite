# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Create and query agreements

  Background:
      Given the default repository is created
        And I am using a "testco" client

  Scenario: Get an agreement via the query service
      Given an onboarded offer for an asset
        And I record an agreement for the offer

       When I query for the agreement

       Then I should receive the agreement
        And I can verify that the asset is covered by the agreement
