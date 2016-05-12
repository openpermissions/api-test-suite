# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

from behave import given


@given(u'a hubkey s0 \"{hk0}\"')
def given_a_hubkey0(context, hk0):
  context.id_map = {
        'hub_key0': hk0
  }


@given(u'the request body is the "{obj}" "{attr}"')
def added_ids(context, obj, attr):
    context.body=getattr(context, obj)[attr]


@given(u'the request body is the "{obj}"')
def added_ids(context, obj):
    context.body = getattr(context, obj)


@given(u'the additional id \"{source_id_type}\" \"{source_id}\" has been attached to the asset')
def added_ids(context, source_id_type, source_id):
    context.id_to_be_attached = {
        'ids': [
            {
             'source_id_type': source_id_type,
             'source_id': source_id
            }
        ]
    }

    context.clean_execute_steps(u"""
       Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository
        And the request body is the "id_to_be_attached"
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        And the additional IDs endpoint for the new asset

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response should not have key "errors"
     """)
