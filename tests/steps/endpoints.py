# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

"""
module for logic and steps related to service endpoints
"""
import re

from behave import step

from config import R2RML_MAPPING_URLS


ENDPOINTS = {
    'accounts': {
        'repositories': '/repositories',
        'repository': '/repositories/{}',
        'login': '/login',
        'links': '/links',
        'organisations': '/organisations',
        'organisation': '/organisations/{}',
        'organisation repositories': '/organisations/{}/repositories',
        'organisation services': '/organisations/{}/services',
        'services': '/services',
        'service': '/services/{}',
        'service types': '/services/types',
        'secrets': '/services/{}/secrets',
        'secret': '/services/{}/secrets/{}',
        'users': '/users',
        'user': '/users/{}',
        'user roles': '/users/{}/roles',
        'user verify': '/users/{}/verify',
        'user password': '/users/{}/password',
        'user organisations': '/users/{}/organisations',
        'user organisation': '/users/{}/organisations/{}',
        'roles': '/roles',
        'role': '/roles/{}',
        'root': ''
    },

    'auth': {
        'verify': '/verify',
        'token': '/token',
        'root': ''
    },

    'identity': {
        'asset': '/asset',
        'offer': '/offer',
        'agreement': '/agreement',
        'capabilities': '/capabilities',
        'root': ''
    },

    'index': {
        'root': '',
        'notifications': '/notifications',
        'asset': '/entity-types/asset/repositories',
    },

    'onboarding': {
        'assets': '/repositories/{}/assets',
        'capabilities': '/capabilities',
        'root': ''},

    'query': {
        'licensors': '/licensors',
        'entities': '/entities',
        'entities_via_entity_id': '/entities/{}/{}/{}',
        'search offers': '/search/offers',
        'root': ''},

    'repository': {
        'agreements': '/repositories/{}/agreements',
        'agreement': '/repositories/{}/agreements/{}',
        'agreement_coverage': '/repositories/{}/agreements/{}/coverage',
        'licensors': '/repositories/{}/licensors',
        'offers': '/repositories/{}/offers',
        'offer': '/repositories/{}/offers/{}',
        'assets': '/repositories/{}/assets',
        'asset': '/repositories/{}/assets/{}',
        'asset ids': '/repositories/{}/assets/{}/ids',
        'sets': '/repositories/{}/sets',
        'set': '/repositories/{}/sets/{}',
        'set assets': '/repositories/{}/sets/{}/assets',
        'set asset': '/repositories/{}/sets/{}/assets/{}',
        'search offers': '/repositories/{}/search/offers',
        'identifiers': '/repositories/{}/assets/identifiers',
        'capabilities': '/capabilities',
        'root': ''},

    'template': {'root': ''},

    'transformation': {
        'assets': '/assets',
        'capabilities': '/capabilities',
        'root': ''},
}


def get_endpoint(service_name, endpoint_name):
    service_endpoints = ENDPOINTS[service_name]
    if service_name == 'index':
        if endpoint_name.startswith('entity-types'):
            return '/{}'.format(endpoint_name)
        else:
            return service_endpoints.get(endpoint_name, endpoint_name)
    else:
        return service_endpoints[endpoint_name]


@step(u'the "{endpoint_name}" endpoint')
def set_endpoint(context, endpoint_name):
    context.endpoint_name = endpoint_name
    context.endpoint = get_endpoint(context.service_name, endpoint_name)


@step(u'the endpoint has query parameter "{key}" equal to "{value}"')
def set_endpoint_with_query_string(context, key, value):
    query_string_regex = re.compile(r'\?\w+=')
    if re.search(query_string_regex, context.endpoint):
        params = '&{}={}'.format(key, value)
    else:
        params = '?{}={}'.format(key, value)
    context.endpoint += params


@step(u'the endpoint has a valid "{content_type}" r2rml_url query parameter')
def set_endpoint_with_r2rml_url_query_param(context, content_type):
    context.endpoint += '?{}={}'.format(
        'r2rml_url', R2RML_MAPPING_URLS[content_type])


@step(u'the "{endpoint_name}" endpoint for "{resource_id}"')
def set_endpoint_for_id(context, endpoint_name, resource_id):
    context.endpoint_name = endpoint_name
    context.endpoint = get_endpoint(
        context.service_name, endpoint_name).format(resource_id)


@step(u'the "{endpoint_name}" endpoint for the {resource}')
def set_endpoint_for_resource(context, endpoint_name, resource):
    resource_id = getattr(context, resource)['id']
    context.endpoint_name = endpoint_name
    context.endpoint = get_endpoint(
        context.service_name, endpoint_name).format(resource_id)
