# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


@when(u'I request to generate "{num_generate}" and create "{num_create}" new identifiers for a "{id_type}"')
def step_impl(context, num_generate, num_create, id_type):
    assert False


@then(u'I should receive "{num_generate}" generated and "{num_created}" created unique "{id_type}" identifiers')
def step_impl(context, num_generate, num_create, id_type):
    assert False


@when(u'I request a number of new "{id_type}" identifiers greater than the maximum allowed')
def step_impl(context, id_type):
    assert False


@then(u'I should receive an error message that indicates that the request is greater than the maximum allowed')
def step_impl(context):
    assert False


@when(u'I request a new identifier for a "{id_type}"')
def step_impl(context, id_type):
    assert False


@then(u'I should receive a generated unique "{id_type}" identifier')
def step_impl(context, id_type):
    assert False


@when(u'I request to generate a new identifier for a "{id_type}"')
def step_impl(context, id_type):
    assert False


@then(u'I should receive a unique "{id_type}" identifier')
def step_impl(context, id_type):
    assert False
