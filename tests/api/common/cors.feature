# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

Feature: Support CORS


  Scenario Outline: Cross-origin OPTIONS request
      Given the "<service>" service
        And the "<endpoint>" endpoint

       When I make a "OPTIONS" request

       Then I should receive a "200" response code
        And response header "Access-Control-Allow-Origin" should be "*"
        And response header "Access-Control-Allow-Headers" should be "Content-Type, Authorization, Accept, X-Requested-With"
        And response header "Access-Control-Allow-Methods" should be "OPTIONS, TRACE, GET, HEAD, POST, PUT, PATCH, DELETE"

        Examples:
            | service    | endpoint          |
            | accounts   | login             |
            | accounts   | organisations     |
            | accounts   | root              |
            | accounts   | services          |
            | accounts   | user organisation |
            | accounts   | users             |
            | index      | root              |
            | query      | licensors         |
            | query      | root              |
            | repository | assets            |
            | repository | offers            |
            | repository | root              |


  Scenario Outline: Cross-origin request
      Given the "<service>" service
        And the "<endpoint>" endpoint

       When I make a "<method>" request

        # NOTE: not checking the response code because not every endpoint implements all methods
       Then response header "Access-Control-Allow-Origin" should be "*"

        Examples:
            | service    | endpoint          | method |
            | accounts   | login             | GET    |
            | accounts   | login             | POST   |
            | accounts   | organisations     | GET    |
            | accounts   | organisations     | POST   |
            | accounts   | root              | GET    |
            | accounts   | root              | POST   |
            | accounts   | services          | GET    |
            | accounts   | services          | POST   |
            | accounts   | user organisation | GET    |
            | accounts   | user organisation | POST   |
            | accounts   | users             | GET    |
            | accounts   | users             | POST   |
            | index      | root              | GET    |
            | query      | licensors         | GET    |
            | query      | licensors         | POST   |
            | query      | root              | GET    |
            | query      | root              | POST   |
            | repository | assets            | GET    |
            | repository | assets            | POST   |
            | repository | offers            | GET    |
            | repository | offers            | POST   |
            | repository | root              | GET    |
            | repository | root              | POST   |
