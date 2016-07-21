# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

import json
import uuid
import requests

from bass.hubkey import generate_hub_key
from behave import given, when, then
from chub.oauth2 import Delegate, Write

from repository import COMMON_ASSET_DETAILS
from general import get_client_secret, get_endpoint

import config

REQUEST_TIMEOUT = 240


def generate_offer_ids(context, count):
    """
    Generate offer ids
    :param count: number of offers to generate
    :return: the offer ids
    """
    for i in xrange(int(count)):
        yield context.offer_ids[i]


def make_asset(offer_ids, set_ids):
    """
    Create an asset dictionary for onboarding service
    :param offer_ids: the offers available on the asset
    :return: the asset
    """
    source_id = str(uuid.uuid4()).replace("-", "")
    asset = {
        'source_ids': [
            {
                'source_id': source_id,
                'source_id_type': COMMON_ASSET_DETAILS['source_id_type']
            }
        ],
        'description': 'A picture with id {}'.format(source_id),
        'offer_ids': list(offer_ids),
        'set_ids': list(set_ids)
    }
    return asset


def convert_assets_to_csv(assets):
    """
    convert assets from a list of dictionaries to csv
    :param assets: a list of asset in dictionary format
    :returns: a sting representing the csv format of the assets
    """
    headers = 'source_id_types,source_ids,offer_ids,description,set_ids'
    result = [headers]
    for asset in assets:
        source_ids = asset['source_ids']
        source_id_types = '~'.join([item['source_id_type']
                                    for item in source_ids])
        source_ids = '~'.join([item['source_id'] for item in source_ids])
        offer_ids = '~'.join(asset['offer_ids'])
        set_ids = '~'.join(asset['set_ids'])
        description = asset.get('description', '')
        row = ','.join([source_id_types, source_ids, offer_ids, description, set_ids])
        result.append(row)
    return '\n'.join(result)


def delegate_scope(context):
    return Delegate(
        context.organisation_services['toppco']['onboarding'][0]['location'],
        Write(context.repository['id']))


def get_auth_token(context, scope):
    """
    Get a token from the auth service to allow access to a service
    :param context: context of the test
    :return: the token
    """
    secret = get_client_secret(context)

    data = {
        'grant_type': 'client_credentials',
        'scope': scope
    }
    response = requests.post(
        '{}/token'.format(context.services['auth']),
        data=data,
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
        timeout=REQUEST_TIMEOUT,
        verify=context.keychain['CA_CRT'],
        auth=(context.client_id, secret)
    )

    return response.json()['access_token']


@given(u'the default repository is created')
def create_default_repo(context):
    context.clean_execute_steps(u"""
        Given the "repository" service
        And the repository "{}" belonging to "{}"
        """.format(
            COMMON_ASSET_DETAILS['organisation_repo'],
            COMMON_ASSET_DETAILS['organisation_id']
    ))


@given(u'I onboard an asset in "{format}" format for the offer sets')
@given(u'I onboard an asset in "{format}" format for the offers')
def onboard_asset(context, format='json'):
    token = get_auth_token(context, delegate_scope(context))
    context.asset = make_asset(getattr(context, "offer_ids", []), getattr(context, "set_ids", []))
    context.id_map = context.asset['source_ids'][0]

    if format == 'json':
        headers = {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            'Accept-Charset': 'utf-8',
            'Authorization': 'Bearer ' + token}
        endpoint = '{}/repositories/{}/assets'.format(
            context.services['onboarding'],
            context.repository['id']
        )
        context.response = context.http_client.post(
            endpoint,
            timeout=REQUEST_TIMEOUT,
            headers=headers,
            data=json.dumps([context.asset]),
            verify=context.keychain['CA_CRT']
        )
    elif format == 'csv':
        headers = {
            'Content-Type': 'text/csv; charset=utf-8',
            'Accept': 'application/json',
            'Accept-Charset': 'utf-8',
            'Authorization': 'Bearer ' + token}
        asset = convert_assets_to_csv([context.asset])
        endpoint = '{}/repositories/{}/assets'.format(
            context.services['onboarding'],
            context.repository['id']
        )
        context.response = context.http_client.post(
            endpoint,
            timeout=REQUEST_TIMEOUT,
            headers=headers,
            data=asset,
            verify=context.keychain['CA_CRT']
        )
    else:
        raise ValueError('unsupported format {}'.format(format))

    return context.response.json()


@given('an onboarded offer for an asset')
def onboarded_offer_for_asset(context):
    context.clean_execute_steps(u'Given "1" offers have already been onboarded')
    context.asset = onboard_asset(context)['data'][0]


@given(u'I record an agreement for the offer')
def add_agreement(context):
    token = get_auth_token(context, Write(context.repository['id']))
    offer_id = context.offer_ids[0]

    # TODO: this should not be the final API endpoint...
    endpoint = get_endpoint('repository', 'agreements').format(
        context.repository['id'])
    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
        'Authorization': 'Bearer ' + token
    }

    response = context.http_client.post(
        context.services['repository'] + endpoint,
        timeout=REQUEST_TIMEOUT,
        headers=headers,
        data=json.dumps({'party_id': '235813',
                         'offer_id': offer_id,
                         'asset_ids': [context.asset['entity_id']]}),
        verify=context.keychain['CA_CRT']
    )

    context.agreement_id = response.json()['data']['id']


@when(u'I query for the offers for the asset')
def query_offers(context):
    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8'}
    body = context.asset['source_ids']
    endpoint = '{}/search/offers'.format(
        context.services['query']
    )

    context.response = context.http_client.post(
        endpoint,
        timeout=REQUEST_TIMEOUT,
        headers=headers,
        data=json.dumps(body),
        verify=context.keychain['CA_CRT']
    )
    context.response_object = context.response.json()


@when(u'I query for the agreement')
def query_agreement(context):
    url = context.services['query'] + get_endpoint('query', 'entities')
    hub_key = generate_hub_key('localhost',
                               config.hub_id,
                               context.repository['id'],
                               'agreement',
                               context.agreement_id)
    context.response = context.http_client.get(url, params={'hub_key': hub_key})


@then(u'I will receive the {no_of_lic_offs} offers')
def receive_offers(context, no_of_lic_offs):
    returned_offer_ids = [
        offer for offer
        in context.response_object['data'][0]['offers']
    ]
    assert len(returned_offer_ids) == len(context.offer_ids)


@given(u'I onboard an asset that has a licensor')
def onboard_asset_with_supplier(context):
    token = get_auth_token(context, delegate_scope(context))
    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
        'Authorization': 'Bearer ' + token}
    context.asset = make_asset(generate_offer_ids(context, count=1),[])
    context.id_map = context.asset['source_ids'][0]

    endpoint = '{}/repositories/{}/assets'.format(
        context.services['onboarding'],
        context.repository['id']
    )
    context.response = context.http_client.post(
        endpoint,
        timeout=REQUEST_TIMEOUT,
        headers=headers,
        data=json.dumps([context.asset]),
        verify=context.keychain['CA_CRT']
    )


@when(u'I query for the licensor for that asset')
def query_for_licensor(context):
    token = get_auth_token(context, delegate_scope(context))
    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
        'Authorization': 'Bearer ' + token}
    params = context.asset['source_ids'][0]
    endpoint = '{}/licensors'.format(
        context.services['query']
    )
    context.response = context.http_client.get(
        endpoint,
        timeout=REQUEST_TIMEOUT,
        headers=headers,
        params=params,
        verify=context.keychain['CA_CRT']
    )
    context.response_object = context.response.json()


@then(u'I will receive that licensor')
def check_supplier(context):
    asset = context.response_object['data']
    licensor = asset[0]['id']
    assert licensor == COMMON_ASSET_DETAILS['organisation_id']


@then(u'I should receive the agreement')
def check_agreement(context):
    assert context.response.status_code == 200
    graph = context.response.json()['data']['@graph']
    agreement = [x for x in graph if 'Agreement' in x['@type']][0]

    assert agreement['@id'] == 'id:' + context.agreement_id


@then(u'I can verify that the asset is covered by the agreement')
def check_agreement_via_endpoint(context):
    context.agreement = {'id': context.agreement_id}
    context.params = {}
    context.params["asset_ids"] = [context.asset["entity_id"]]
    context.execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "read" access to the repository
        And the "agreement_coverage" endpoint of the repository for the "agreement" "id"
        #And request body has a key of "asset_ids" is a singleton "{asset_id}"

       When I make a "GET" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
        And response header "Content-Type" should be "application/json; charset=UTF-8"
        And response "data" should be a "dictionary" with key "covered_by_agreement"
    """)
