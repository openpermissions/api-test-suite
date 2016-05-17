# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

from __future__ import unicode_literals

import uuid
import json
from urlparse import urlparse, urlunparse

from chub.api import API
from behave import given

from .general import (
    get_endpoint, get_organisation_services, get_organisation_repositories)


@given('parameter "{parameter}" is a unique location')
def unique_location(context, parameter):
    unique_path = uuid.uuid4()
    context.execute_steps(
        'Given parameter "{}" is'
        ' "http://testco-local-{}"'.format(parameter, unique_path))


@given('parameter "{parameter}" is a unique email address')
def unique_email_address(context, parameter):
    context.execute_steps('Given parameter "{}" is '
                          '"{}@example.com"'.format(parameter, uuid.uuid4()))


@given('parameter "{parameter}" is a valid set of service permissions')
def valid_permission_set(context, parameter):
    context.params[parameter] = [
        {'type': 'organisation_id', 'value': 'testco', 'permission': 'rw'}
    ]


@given('parameter "{parameter}" is a valid set of repository permissions')
def valid_repository_permission_set(context, parameter):
    context.params[parameter] = [
        {'type': 'organisation_id', 'value': 'testco', 'permission': 'w'}
    ]


@given('the organisation has "{access}" access to the service')
def grant_given_access(context, access, organisation_id=None, service=None):
    # TODO: Can this be replaced with general.grant_given_access?
    if organisation_id is None:
        organisation_id = context.organisation['id']

    if service is None:
        service = context.service

    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = context.token

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


@given('"{organisation_id}" may {access} the service')
def may_access(context, organisation_id, access):
    grant_given_access(context, access[0], organisation_id)


@given('"{organisation_id}" may {access} the "{service_org}" "{service_type}" service')
def may_access_organisation_service(context, organisation_id, access,
                                    service_org, service_type):
    service = get_organisation_service(context, service_org, service_type)
    grant_given_access(context, access[0], organisation_id=organisation_id,
                       service=service)


@given('"{organisation_id}" may {access} the repository\'s service')
def may_access_repo_service(context, organisation_id, access):
    service = context.repository['service']
    grant_given_access(context, access[0], organisation_id=organisation_id,
                       service=service)


@given('"{organisation_id}" may {access} the repository')
def may_access_repo(context, organisation_id, access):
    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = context.token

    repository_id = context.repository['id']
    permissions = context.repository['permissions']

    data = {
        'type': 'organisation_id',
        'value': organisation_id,
        'permission': access[0]
    }
    if data not in permissions:
        permissions.append({
            'type': 'organisation_id',
            'value': organisation_id,
            'permission': access[0]
        })
        response = client.accounts.repositories[repository_id].put(permissions=permissions)

        if response.status != 200:
            raise Exception('Error updating permissions')


@given('"{organisation_id}" cannot access the repository')
def cannot_access_repo(context, organisation_id):
    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = context.token

    repository_id = context.repository['id']
    permissions = [x for x in context.repository['permissions']
                   if x['value'] != organisation_id]
    response = client.accounts.repositories[repository_id].put(permissions=permissions)

    if response.status != 200:
        raise Exception('Error updating permissions')


@given('"{organisation_id}" cannot access the repository\'s service')
def cannot_access_repo_service(context, organisation_id):
    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = context.token

    service_id = context.repository['service']['id']
    permissions = [x for x in context.repository['service']['permissions']
                   if x['value'] != organisation_id]
    permissions.append({
        'type': 'organisation_id',
        'value': organisation_id,
        'permission': '-'
    })
    response = client.accounts.services[service_id].put(permissions=permissions)

    if response.status != 200:
        raise Exception('Error updating permissions')


@given('the organisation has access to the "{service}" service')
@given('the service is authorized to access the "{service}" service')
def grant_access_to_service(context, service):
    url = urlparse(context.services['accounts'])
    client = API(urlunparse([url.scheme, url.netloc, '', '', '', '']),
                 async=False, validate_cert=False)
    client.default_headers['Authorization'] = context.token
    # TODO: THE REPOSITORY is the term used before
    # we have multiple repositories as default
    # the term needs updating and we should assume
    # the new default of at least two repositories
    if service == 'repository':
        service_id = context.the_repository['id']
        response = client.accounts.services[service_id].get()
        permissions = response['data'].get('permissions', [])
    else:
        response = client.accounts.services.get(name=service)

        if not response['data']:
            raise Exception('"{}" service not found'.format(service))

        service_id = response['data'][0]['id']
        permissions = response['data'][0].get('permissions', [])
    new_permission = {
        'type': 'organisation_id',
        'value': context.service['organisation_id'],
        'permission': 'rw'}
    if new_permission not in permissions:
        permissions.append(new_permission)
    response = client.accounts.services[service_id].put(
        permissions=permissions)

    if response.status != 200:
        raise Exception('Error updating permissions')


@given('the existing user "{user_id}"')
def get_user(context, user_id):
    context.user = {'password': 'password'}

    context.clean_execute_steps("""
        Given the "accounts" service
          And parameter "email" is "opp@example.com"
          And parameter "password" is "password"
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
         When I make a "POST" request to the "login" endpoint
    """)
    token = context.response_object['data']['token']

    context.clean_execute_steps("""
        Given the "accounts" service
          And Header "Accept" is "application/json"
          And Header "Authorization" is "{}"
        When I make a "GET" request to the "user" endpoint with "{}"
    """.format(token, user_id))
    context.user.update(context.response_object['data'])


@given('a new user')
@given('another new user')
def create_user(context):
    context.user = {
        'email': str(uuid.uuid4()) + '@example.com',
        'password': 'password',
        'has_agreed_to_terms': True
    }

    context.clean_execute_steps("""
        Given the "accounts" service
          And parameter "email" is the user email
          And parameter "first_name" is a unique string
          And parameter "last_name" is a unique string
          And parameter "password" is the user password
          And parameter "has_agreed_to_terms" is boolean "true"
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
         When I make a "POST" request to the "users" endpoint
    """)
    context.user.update(context.response_object['data'])


@given('a new role')
@given('another new role')
def create_role(context):
    orig_user = context.user if hasattr(context, 'user') else None
    orig_token = context.token if hasattr(context, 'token') else None

    context.clean_execute_steps("""
      Given the "accounts" service
        And the existing user "testadmin"
        And the user is logged in
        And Header "Authorization" is a valid token
        And parameter "name" is a unique string
        And Header "Content-Type" is "application/json"
        And Header "Accept" is "application/json"
        When I make a "POST" request to the "roles" endpoint
    """)
    context.role = context.response_object['data'].copy()
    context.user = orig_user
    context.token = orig_token


@given('a new organisation')
@given('another new organisation')
def create_organisation(context):
    context.clean_execute_steps("""
       Given the "accounts" service
         And the user is logged in
         And parameter "name" is a unique string
         And Header "Authorization" is a valid token
         And Header "Content-Type" is "application/json"
         And Header "Accept" is "application/json"
        When I make a "POST" request to the "organisations" endpoint
    """)
    context.organisation = context.response_object['data'].copy()


@given('the existing organisation "{organisation_id}"')
def get_organisation(context, organisation_id):
    if getattr(context, 'organisation', {}).get('id') == organisation_id:
        return context.organisation

    with context.keep_attributes('user', 'token'):
        context.clean_execute_steps("""
            Given the "accounts" service
            And the existing user "testadmin"
            And the user is logged in
            And Header "Authorization" is a valid token
            And Header "Accept" is "application/json"
            When I make a "GET" request to the "organisation" endpoint with "{}"
        """.format(organisation_id))
    organisation = context.response_object['data'].copy()
    context.organisation = organisation
    return organisation


@given('"{organisation_id}" has an "{service_type}" service')
@given('"{organisation_id}" has a "{service_type}" service')
@given('the existing organisation "{organisation_id}" with an "{service_type}" service')
@given('the existing organisation "{organisation_id}" with a "{service_type}" service')
def get_organisation_service(context, organisation_id, service_type):
    organisation = get_organisation(context, organisation_id)
    context.organisation = organisation

    existing_services = context.organisation_services[organisation_id][service_type]
    if existing_services:
        service = existing_services[0]
        context.service = service
        return service

    try:
        service = get_organisation_services(
            context, organisation_id, service_type)[0]
    except IndexError:
        service = create_service(context, service_type)

    context.service = service
    existing_services.appendleft(service)

    return service


@given('"{organisation_id}" has an approved "{service_type}" service')
def get_approved_organisation_service(context, organisation_id, service_type):
    service = get_organisation_service(context, organisation_id, service_type)
    if service['state'] != 'approved':
        approve_service(context)


@given('"{organisation_id}" has a pending "{service_type}" service')
def get_approved_organisation_service(context, organisation_id, service_type):
    service = get_organisation_service(context, organisation_id, service_type)
    if service['state'] != 'pending':
        pending_service(context)


@given(u'the repository "{repository_name}" belonging to "{organisation_id}"')
def organisation_and_its_repository(context, repository_name, organisation_id):
    try:
        repository = get_organisation_repositories(
            context, organisation_id, repository_name)[0]
    except IndexError:
        repository = create_repository(
            context, organisation_id, repository_name)
    context.repository = repository
    # make sure toppco can access all repositories so they can be indexed
    context.execute_steps('Given "toppco" may read from the repository')
    context.repositories[repository_name] = repository


@given('the user has requested to join the organisation')
def request_join_organisation(context):
    context.clean_execute_steps("""
        Given the "accounts" service
          And the user is logged in
          And Header "Authorization" is a valid token
          And parameter "organisation_id" is the organisation id
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
         When I make a "POST" request to the "user organisations" endpoint with the user id
    """)


@given('the user has joined the organisation')
def join_organisation(context):
    request_join_organisation(context)

    orig_user = context.user if hasattr(context, 'user') else None
    orig_token = context.token if hasattr(context, 'token') else None
    orig_headers = context.headers if hasattr(context, 'headers') else None
    # Need this step to get correct permissions to update users organisation join state
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
    """)
    context.user = orig_user
    context.clean_execute_steps("""
        Given the "accounts" service
          And Header "Authorization" is a valid token
          And parameter "state" is "approved"
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
         When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs
    """)
    context.token = orig_token
    context.headers = orig_headers


@given('the user has role "{role}" for the organisation')
def get_org_admin_user(context, role):
    orig_user = context.user if hasattr(context, 'user') else None

    join_organisation(context)
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
          And Header "Authorization" is a valid token
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
          And parameter "role" is "{}"
          And parameter "state" is "approved"
          And the existing user "{}"
         When I make a "PUT" request to the "user organisation" endpoint with user & organisation IDs
    """.format(role, orig_user['id']))
    context.user = orig_user


@given('the organisation has an "{service_type}" service')
@given('the organisation has a "{service_type}" service')
def create_service(context, service_type):
    context.clean_execute_steps("""
       Given the "accounts" service
         And parameter "name" is a unique string
         And parameter "location" is a unique location
         And parameter "service_type" is "{}"
         And Header "Authorization" is a valid token
         And Header "Content-Type" is "application/json"
         And Header "Accept" is "application/json"
        When I make a "POST" request to the "organisation services" endpoint with the organisation id
    """.format(service_type))
    service = context.response_object['data'].copy()
    context.service = service
    return service


@given('the service has a client secret')
def create_service_secret(context):
    context.clean_execute_steps("""
       Given the "accounts" service
         And Header "Authorization" is a valid token
         And Header "Content-Type" is "application/json"
         And Header "Accept" is "application/json"
        When I make a "POST" request to the "secrets" endpoint with the service id
    """)
    secret = context.response_object['data']
    context.secret = secret
    return secret


def create_repository(context, organisation_id, name):
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
    """)
    url = context.services['accounts'] + get_endpoint(
        'accounts', 'organisation repositories').format(organisation_id)
    data = json.dumps(
        {'name': name, 'service_id': context.the_repository['id']})
    headers = {'Authorization': context.token}
    response = context.http_client.post(
        url, data=data, headers=headers).json()
    repository = response['data']
    return repository


@given('the user is logged in')
def login(context):
    context.clean_execute_steps("""
        Given the "accounts" service
          And parameter "email" is the user email
          And parameter "password" is the user password
          And Header "Content-Type" is "application/json"
          And Header "Accept" is "application/json"
         When I make a "POST" request to the "login" endpoint
    """)

    context.token = context.response_object['data']['token']


@given('Header "Authorization" is a valid token')
def given_auth_token(context):
    try:
        token = context.token
    except AttributeError:
        context.clean_execute_steps("""
            Given the "accounts" service
              And the existing user "testadmin"
              And the user is logged in""")
        token = context.response_object['data']['token']
    context.execute_steps('Given Header "Authorization" is "{}"'.format(token))


@given('the service contains a repository owned by the organisation')
def given_service_has_repository(context):
    context.clean_execute_steps("""
       Given the "accounts" service
         And parameter "name" is a unique string
         And parameter "service_id" is the service id
         And parameter "organisation_id" is the organisation id
         And Header "Authorization" is a valid token
         And Header "Content-Type" is "application/json"
         And Header "Accept" is "application/json"
        When I make a "POST" request to the "organisation repositories" endpoint with the organisation id
    """)
    context.repository = context.response_object['data'].copy()


@given('the repository service contains a repository owned by "{organisation_id}"')
def given_org_repo_has_repository(context, organisation_id):
    context.clean_execute_steps("""
       Given the "accounts" service
         And parameter "name" is a unique string
         And parameter "service_id" is "{service_id}"
         And parameter "organisation_id" is "{organisation_id}"
         And Header "Authorization" is a valid token
         And Header "Content-Type" is "application/json"
         And Header "Accept" is "application/json"
        When I make a "POST" request to the "organisation repositories" endpoint with "{organisation_id}"
    """.format(service_id=context.the_repository['id'], organisation_id=organisation_id))
    context.repository = context.response_object['data'].copy()


@given(u"the service is approved")
def approve_service(context):
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
          And Header "Authorization" is a valid token
          And Header "Accept" is "application/json"
          And parameter "state" is "approved"
        When I make a "PUT" request to the "service" endpoint with the service id
    """)


@given(u"the service is pending")
def pending_service(context):
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
          And Header "Authorization" is a valid token
          And Header "Accept" is "application/json"
          And parameter "state" is "pending"
        When I make a "PUT" request to the "service" endpoint with the service id
    """)


@given(u"the repository is approved")
def approve_repository(context):
    context.clean_execute_steps("""
        Given the "accounts" service
          And the existing user "testadmin"
          And the user is logged in
          And Header "Authorization" is a valid token
          And Header "Accept" is "application/json"
          And parameter "state" is "approved"
        When I make a "PUT" request to the "repository" endpoint with the repository id
    """)

@given(u"the \"{org_id}\" reference link for \"{idtype}\" has been set to \"{url}\"")
def set_toppco_reference_link(context, org_id, idtype, url, user="harry"):
    if "/" in org_id:
        user = org_id.split("/")[1]
        org_id = org_id.split("/")[0]

    context.reference_link = {'links': {idtype: url}, 'redirect_id_type': idtype}
    context.clean_execute_steps("""
      Given the "accounts" service
        And the existing organisation "{org_id}"
        And the existing user "{user}"
        And the user is logged in
        And parameter "reference_links" is the reference_link
        And Header "Authorization" is a valid token

       When I make a "PUT" request to the "organisation" endpoint with the organisation id

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be an object with "id" of type "unicode"
        And response "data" should be an object with "name" of type "unicode"
        And response "data" should be an object with "state" of type "unicode"
        And response should not have key "errors"
    """.format(org_id=org_id,user=user))