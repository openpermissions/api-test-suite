# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

from __future__ import unicode_literals

from behave import given, then
import jwt

from .general import (
    make_request, setup_access, grant_given_access,
    get_existing_service, get_client_secret)


@given('the client ID is the service ID')
def set_client_id(context):
    context.client_id = context.service['id']


@given('I am using a "{organisation_id}" client')
@given('the client ID is the "{organisation_id}" "{service_type}" service ID')
def set_organisation_client_id(context, organisation_id, service_type='external'):
    service = get_existing_service(context, organisation_id, service_type)
    context.client_id = service['id']


@given('the client ID is the "{repository_name}" repository\'s service ID')
def set_repository_service_client_id(context, repository_name):
    context.client_id = context.repositories[repository_name]['service']['id']


@given('the request is authenticated with the client ID and secret')
def basic_auth(context):
    with context.keep_attributes('params', 'headers', 'response_object'):
        secret = get_client_secret(context)
        context.auth = (context.client_id, secret)

    context.headers.pop('Authorization', None)


@given(u'the client has an access token granting "{access_type}" access')
@given(u'the client has an access token granting "{access_type}" access to the "{organisation_id}" "{service_type}" service')
def generate_token(context, access_type, organisation_id=None, service_type=None):
    with context.keep_request_data(), context.keep_attributes('service'):
        context.service = {'id': context.client_id}
        context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
          And Header "Authorization" is a valid token
         When I make a "GET" request to the "service" endpoint with the service id""")
        service = context.response_object['data']
        if organisation_id and service_type:
            grant_given_access(
                context,
                access_type[0],
                organisation_id=organisation_id,
                service=service)
        basic_auth(context)

        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'

        if service_type:
            service = get_existing_service(
                context, organisation_id, service_type)
            context.params['scope'] = '{}[{}]'.format(access_type, service['id'])
        else:
            context.params['scope'] = access_type

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response_object['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given(u'there is no access token')
def no_access_token(context):
    context.headers['Authorization'] = None


@given('requested an access token to "read"')
def requested_read_token(context):
    with context.keep_attributes('params', 'headers'):
        set_client_id(context)
        basic_auth(context)

        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('requested an access token to write to the "{organisation_id}" "{service_type}" service')
def requested_write_token(context, organisation_id, service_type):
    with context.keep_request_data():
        set_client_id(context)
        basic_auth(context)

        service = context.organisation_services[organisation_id][service_type][0]

        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        context.params['scope'] = 'write[{}]'.format(service['id'])
        context.body = None  # make sure the body is cleared

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('requested an access token to {access_type} the repository')
def requested_write_token(context, access_type):
    access = access_type.split()[0]
    if access not in ('read', 'write'):
        raise ValueError('Expected access type to be read or write')

    with context.keep_request_data():
        set_client_id(context)
        basic_auth(context)
        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        context.params['scope'] = '{}[{}]'.format(access, context.repository['id'])
        context.body = None  # make sure the body is cleared

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('the client has an access token granting "{access_type}" access to the repository')
def requested_write_token(context, access_type):
    with context.keep_request_data():
        basic_auth(context)
        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        context.params['scope'] = '{}[{}]'.format(access_type, context.repository['id'])
        context.body = None  # make sure the body is cleared

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('the client has an access token granting write access to the repository via the "{organisation_id}" "{service_type}" service')
def requested_write_repo_delegate_token(context, organisation_id, service_type):
    with context.keep_attributes('params', 'headers'):
        setup_access(context, context.client_id, 'write', organisation_id, service_type)
        basic_auth(context)

        service = context.organisation_services[organisation_id][service_type][0]

        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        context.params['scope'] = 'delegate[{}]:write[{}]'.format(
            service['id'], context.repository['id'])

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('the client has an access token granting write access to the "{organisation_id}" "{service_type}" service via the "{delegate_organisation}" "{delegate_type}" service')
def requested_write_service_delegate_token(context, organisation_id, service_type, delegate_organisation, delegate_type):
    with context.keep_attributes('params', 'headers'):
        basic_auth(context)

        service = context.organisation_services[organisation_id][service_type][0]
        delegate = context.organisation_services[delegate_organisation][delegate_type][0]

        context.headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        context.params['grant_type'] = 'client_credentials'
        context.params['scope'] = 'delegate[{}]:write[{}]'.format(delegate['id'],
                                                                  service['id'])

        make_request(context,
                     'POST',
                     endpoint='token',
                     service_name='auth')

        context.access_token = context.response.json()['access_token']
    context.headers['Authorization'] = 'Bearer ' + context.access_token


@given('the scope is to write to the "{organisation_id}" "{service_type}" service')
def scope_write_organisation_service(context, organisation_id, service_type):
    service = context.organisation_services[organisation_id][service_type][0]
    context.scope = 'write[{}]'.format(service['id'])
    context.params['scope'] = context.scope


@given('the scope is to write to the repository')
def scope_write_to_repository(context):
    context.scope = 'write[{}]'.format(context.repository['id'])
    context.params['scope'] = context.scope


@given('the scope is to write to the repository service')
def scope_write_to_repository_service(context):
    context.scope = 'write[{}]'.format(context.repository['service']['id'])
    context.params['scope'] = context.scope


@given('the scope is to write to the repository via the "{organisation_id}" "{service_type}" service')
def scope_delegate_write_to_repository(context, organisation_id, service_type):
    service = context.organisation_services[organisation_id][service_type][0]
    context.scope = 'delegate[{}]:write[{}]'.format(service['id'],
                                                    context.repository['id'])
    context.params['scope'] = context.scope


@given('the scope is to delegate to a repository')
def scope_delegate_to_repository(context):
    context.scope = 'delegate[{}]:write[{}]'.format(
        context.repository['id'], context.repository['id'])
    context.params['scope'] = context.scope


@given('the scope is to delegate to a service that does not exist')
def scope_delegate_to_repository(context):
    context.scope = 'delegate[does_not_exist]:write[{}]'.format(
        context.repository['id'])
    context.params['scope'] = context.scope


@given('parameter "resource_id" is "{repository_name}" repository\'s ID')
def resource_id_parameter(context, repository_name):
    context.params['resource_id'] = context.repositories[repository_name]['id']


@then('the response should contain JWT "{key}"')
def response_jwt(context, key):
    token = context.response.json()[key]
    context.decoded_token = jwt.decode(token, verify=False)


@then('the JWT "{key}" should be "{value}"')
def response_jwt_value(context, key, value):
    assert context.decoded_token[key] == value


@then('the JWT "{key}" should be the client ID')
def response_jwt_client_id(context, key):
    assert context.decoded_token[key] == context.client_id


@then('the JWT "{key}" should be the scope')
def response_jwt_scope(context, key):
    assert context.decoded_token[key] == context.scope


@then('the JWT scope should be to write to the repository')
def response_jwt_scope_write_repo(context):
    scope = 'write[{}]'.format(context.repository['id'])
    assert context.decoded_token['scope'] == scope
