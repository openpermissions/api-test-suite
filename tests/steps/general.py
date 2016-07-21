# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

"""Behave scenarios steps implementation
"""
from __future__ import unicode_literals

import uuid
from urllib import quote_plus
import datetime
from time import sleep
from urlparse import urlparse, urlunparse

import requests
from bass.hubkey import generate_hub_key
from behave import given, when, then
from chub.api import API

from endpoints import get_endpoint
from http_client import request
from tests import config

@given(u'we wait {seconds} seconds')
def wait_seconds(context, seconds):
    sleep(int(seconds))


@given(u'the "{service_name}" service')
def set_service_name(context, service_name):
    context.service_name = service_name


@given('parameter "token" is a token')
def parameter_auth_token(context):
    context.clean_execute_steps("""
        Given the "auth" service
         When I make a "GET" request to the "token" endpoint
    """)
    context.params['token'] = context.response_object['token']


@given(u'Header "Authorization" is a token')
def set_an_authorization_header(context):
    context.clean_execute_steps("""
        Given the "auth" service
         When I make a "GET" request to the "token" endpoint
    """)
    context.headers['Authorization'] = 'Bearer ' + context.response_object['token']


@given(u'Header "Authorization" is the access token')
def set_the_authorization_header(context):
    context.headers['Authorization'] = 'Bearer ' + context.access_token



@given(u'request body has a key of "{key}" with a value of \'{value}\'')
@given(u'request body has a key of "{key}" with a value of "{value}"')
def set_request_body(context, key, value):
    "Add a key to the request body"
    if not hasattr(context, "body"):
        context.body = {}
    if not context.body:
        context.body = {}
    context.body[key] = value

@given(u'request body has a key of "{key}" with the {obj} {attr}')
@given(u'request body has a key of "{key}" with the value of {obj} {attr}')
def set_request_body_attr(context, key, obj,attr):
    "Add a key to the request body"
    if not hasattr(context, "body"):
        context.body = {}
    if not context.body:
        context.body = {}
    context.body[key] = getattr(context, obj)[attr]

@given(u'request body has a key of "{key}" is a singleton {obj} {attr}')
def set_request_body_attr_array_wrapped(context, key, obj,attr):
    "Add a key to the request body"
    if not hasattr(context, "body"):
        context.body = {}
    if not context.body:
        context.body = {}
    context.body[key] = [ getattr(context, obj)[attr] ]


@given('the agreement\'s hub key is the "hub_key" parameter')
def parameter_hub_key(context):
    hub_key = generate_hub_key('localhost',
                               config.hub_id,
                               context.repository['id'],
                               'agreement',
                               context.agreement['id'])

    context.params['hub_key'] = hub_key

@given('an invalid reference to an agreement')
def invalid_reference_to_an_agreement(context):
    context.repository = {}
    context.repository['id'] = '!NOTVALIDREPOID!'
    context.agreement = {'id': '!NOTVALID!'}


@given('the entities endpoint of the query service for the current {entity_type}')
def entities_param_entity_id(context, entity_type):
    entity_id = getattr(context, entity_type)["id"]
    endpoint = get_endpoint("query", "entities_via_entity_id")
    context.endpoint = endpoint.format(context.repository['id'],
                                       entity_type, entity_id)


@given('parameter "hub_key" is a hub key that does not exist')
def parameter_hub_key_does_not_exist(context):
    fake_hub_key = 'https://localhost/s1/test/{}/agreement/{}'.format(
        uuid.uuid4(), uuid.uuid4())
    context.params['hub_key'] = fake_hub_key


@given(u'I make a "{http_verb}" request')
@when(u'I make a "{http_verb}" request')
@when(u'I make a "{http_verb}" request to the "{endpoint}" endpoint')
@when(u'I make a "{http_verb}" request to the "{endpoint}" endpoint with "{url_param}"')
def make_request(context, http_verb, endpoint=None,
                 url_param=None, path=None, service_name=None, escape_param=True):

    if service_name is None:
        service_name = context.service_name

    base_url = context.services[service_name]

    if not path and endpoint:
        path = get_endpoint(service_name, endpoint)
    elif hasattr(context, 'endpoint') and not path:
        path = context.endpoint

    if url_param:
        if hasattr(url_param, '__iter__'):
            if escape_param:
                url_param = map(quote_plus, url_param)
            path = path.format(*url_param)
        else:
            if escape_param:
                url_param = quote_plus(url_param)
            path = path.format(url_param)

    return request(http_verb, context, base_url + path)

@when(u'I make a "{http_verb}" request with the unescaped {obj} {attr}')
@when(u'I make a "{http_verb}" request to the "{endpoint}" endpoint with the unescaped {obj} {attr}')
def make_request_with_attr(context, http_verb, obj, attr, endpoint=None):
    make_request(context, http_verb, endpoint, getattr(context, obj)[attr], escape_param=False)

@when(u'I make a "{http_verb}" request with the {obj} {attr}')
@when(u'I make a "{http_verb}" request to the "{endpoint}" endpoint with the {obj} {attr}')
def make_request_with_attr(context, http_verb, obj, attr, endpoint=None):
    make_request(context, http_verb, endpoint, getattr(context, obj)[attr])


@when(u'I make a "{http_verb}" request to the "secret" endpoint with service id & secret')
def make_request_with_attr_and_secret(context, http_verb):
    path = get_endpoint(context.service_name, 'secret').format(context.service['id'], context.secret)
    make_request(context, http_verb, path=path)


@when(u'I make a "{http_verb}" request to the "{endpoint}" endpoint with user & organisation IDs')
def make_request_with_attr_user_org(context, http_verb, endpoint):
    path = get_endpoint(context.service_name, endpoint).format(
        quote_plus(getattr(context, 'user')['id']),
        quote_plus(getattr(context, 'organisation')['id']))
    make_request(context, http_verb, path=path)


@then('data object with a "{attribute_name}" array containing "{obj}"')
def data_object_with_array_containing(context, attribute_name, obj):
    assert context.response_object['data']

    data = context.response_object['data']
    assert data[attribute_name]

    array = data[attribute_name]
    assert obj in array


@then(u'the errors should contain an object with "{key1}" of the repository service "{key2}"')
def repo_error_checking(context, key1, key2):
    errors = context.response_object['errors']
    value = context.the_repository[key2]
    assert any(error.get(key1) == value for error in errors)


@then(u'all the errors should have "{key}" of a repository service')
def repo_errors(context, key):
    errors = context.response_object['errors']
    values = [error[key] for error in errors]
    repo_names = [r['name'] for r in context.repository_services]
    assert all(value in repo_names for value in values)


@then(u'with "{key}" item "{index}" as "{var_name}"')
def store_variable(context, key, index, var_name):
    "Store a named variable in context.variables"
    data = context.response_object['data']
    item = data[int(index)]
    if not hasattr(context, "variables"):
        context.variables = {}
    context.variables[var_name] = item


type_checks = {
    'unicode': lambda x: isinstance(x, unicode),
    'datetime': lambda x: datetime.datetime.strptime(x, "%Y-%m-%dT%H:%M:%SZ")}


@then(u'"{variable}" has a key "{key}" of type "{key_type}"')
def check_type_of_key(context, variable, key, key_type):
    "Check that a key in an object in context.variables is of a type"
    item = context.variables[variable][key]
    assert type_checks[key_type](item)


@then(u'"{variable}" has a key "{key}" equals "{value}"')
def check_value_of_key(context, variable, key, value):
    "Check that a key in an object in context.variables has a value"
    item = context.variables[variable][key]
    assert item == value, "{!r} != {!r}".format(item, value)


@then('array "{attribute_name}" should contain the organisation service')
@then('array "{attribute_name}" should contain the service')
def check_organisation_service(context, attribute_name):
    service = context.service.copy()
    for key in ['rev', 'ok']:
        if key in service:
            del service[key]
    assert service in context.response_object[attribute_name]


def get_organisation_services(context, organisation_id, service_type=None):
    with context.keep_request_data(), context.keep_attributes('organisation'):
        context.organisation = {'id': organisation_id}
        context.execute_steps("""
            Given the "accounts" service
            And the existing user "testadmin"
            And the user is logged in
            And Header "Authorization" is a valid token
            And Header "Accept" is "application/json"
            And parameter "organisation_id" is the organisation id

           When I make a "GET" request to the "services" endpoint""")
    services = context.response_object['data']
    if service_type:
        services = [srv for srv in services
                    if srv['service_type'] == service_type]
    return services


def get_organisation_repositories(context, organisation_id, repository_name=None):
    with context.keep_request_data(), context.keep_attributes('organisation'):
        context.organisation = {'id': organisation_id}
        context.execute_steps("""
            Given the "accounts" service
            And the existing user "testadmin"
            And the user is logged in
            And Header "Authorization" is a valid token
            And Header "Accept" is "application/json"
           When I make a "GET" request to the "organisation repositories" endpoint with the organisation id
        """)
    # TODO the accounts service may not return a 200 and an empty list
    # if no repositories are found for the organisation but instead throws
    # an error.
    if not context.response.ok:
        return []
    repositories = context.response_object['data']
    if repository_name:
        repositories = [repo for repo in repositories
                        if repo['name'] == repository_name]
    return repositories


def get_existing_service(context, organisation_id, service_type):
    existing_services = context.organisation_services[organisation_id][service_type]
    if existing_services:
        service = existing_services[0]
    else:
        try:
            service = get_organisation_services(
                context, organisation_id, service_type)[0]
        except IndexError:
            raise Exception('"{}" "{}" service not found. Is it registered?'
                            .format(organisation_id, service_type))
        existing_services.appendleft(service)
    return service


def get_login_token(context):
    # Log in to accounts service
    with context.keep_request_data():
        context.headers['Content-Type'] = 'application/json'
        context.params['email'] = 'opp@example.com'
        context.params['password'] = 'password'
        context.body = None  # make sure the body is cleared
        make_request(context,
                     'POST',
                     endpoint='login',
                     service_name='accounts')
    return context.response_object['data']['token']


def get_client_secret(context):
    accounts_token = get_login_token(context)
    url = '{}/services/{}/secrets'.format(context.services['accounts'],
                                          context.client_id)
    headers = {'Content-Type': 'application/json',
               'Authorization': accounts_token}
    response = requests.get(url, headers=headers,
                            verify=context.keychain['CA_CRT'])
    return response.json()['data'][0]


def grant_given_access(context, access, organisation_id, service):
    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = get_login_token(context)

    permissions = service['permissions']
    permissions = [x for x in permissions if x['value'] != organisation_id]
    permissions.append({
        'type': 'organisation_id',
        'value': organisation_id,
        'permission': access
    })

    response = client.accounts.services[service['id']].put(permissions=permissions)

    if response.status != 200:
        raise Exception('Error updating permissions')


@given(u'the request body is the "{obj}" "{attr}"')
def added_ids(context, obj, attr):
    context.body = getattr(context, obj)[attr]


@given(u'the request body is the "{obj}"')
def added_ids(context, obj):
    context.body = getattr(context, obj)



def setup_access(context, organisation_id, access, service_org, service_type):
    service = get_existing_service(context, service_org, service_type)
    grant_given_access(context, access[0], organisation_id=organisation_id, service=service)
