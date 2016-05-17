# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


from datetime import datetime
from urllib import quote_plus, unquote_plus

import uuid
import random

import rdflib
from rdflib import Graph, URIRef, Literal
from behave import given, when

from environment import clean_step

PREFIXES = {
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "owl": "http://www.w3.org/2002/07/owl#",
    'id': "http://openpermissions.org/ns/id/",
    "odrl": "http://www.w3.org/ns/odrl/2/",
    "op": "http://openpermissions.org/ns/op/1.1/",
    "dc": "http://purl.org/dc/elements/1.1/",
    "dct": "http://purl.org/dc/terms/",
    "olex": "http://openpermissions.org/ns/opex/1.0/",
    'hub': "http://openpermissions.org/ns/hub/"
}

JSON_LD_CONTEXT = dict(PREFIXES)
JSON_LD_CONTEXT.update({
    "@vocab": "http://www.w3.org/ns/odrl/2/",
    "@language": "en",
    'op:alsoIdentifiedBy': {"@container": "@set", "type": "@id"},
    'op:sharedDuties': {"@container": "@set", "type": "@id"},
    'duty': {"@container": "@set", "type": "@id"},
    'prohibition': {"@container": "@set", "type": "@id"},
    'permission': {"@container": "@set", "type": "@id"},
    'constraint': {"@container": "@set", "type": "@id"}
})

COMMON_PREFIXES = "\n".join("@prefix %s: <%s> ." % i for i in PREFIXES.items())+"\n"
TEMPLATE_HUBKEY = "https://openpermissions.org/s1/hub1/{repo_id}/{id_type}/{id}"
TEMPLATE_HUBKEY_V0 = "https://openpermissions.org/s0/hub1/{entity_type}/{org_id}/{source_id_type}/{source_id}"
ASSET_TEMPLATE = """
{prefixes}

id:{id} a op:Asset ;
    op:alsoIdentifiedBy [
                a op:Id ;
                op:id_type hub:{source_id_type} ;
                op:value "{source_id}"
            ] ;
    dct:description "description for {source_id_type} {source_id}" ;
    dct:modified "{timestamp}"^^xsd:dateTime .
"""

MINIMAL_ASSET_TEMPLATE = """
id:{id} a op:Asset ;
        dct:modified "{modified}"^^xsd:dateTime .
"""


ASSET_DIRECT_OFFER_TEMPLATE = """
{prefixes}

id:{offer_id} a op:Policy, odrl:Offer ;
    odrl:target id:{id} .

id:{id} a op:Asset ;
        dct:modified "{modified}"^^xsd:dateTime .
"""

OFFER_ASSET_SELECTOR1 = """
id:{offer_id} a op:Policy, odrl:Offer ;
    odrl:target id:{offer_id}5e1ec104  .

id:{offer_id}5e1ec104 a op:AssetSelector ;
    op:count "1"^^xsd:integer ;
    op:fromSet id:{set_id} ;
    op:selectPolicy op:selected_by_assignee .
"""

ASSET_INDIRECT_OFFER_TEMPLATE = """
{prefixes}
""" + OFFER_ASSET_SELECTOR1 + """

id:{set_id} a op:AssetSet ;
    op:hasElement id:{id} .

id:{id} a  op:Asset;
        dct:modified "{modified}"^^xsd:dateTime .
"""

ASSET_INDIRECT_SET_TEMPLATE = """
{prefixes}

id:{set_id} a op:AssetSet ;
    op:hasElement id:{id} .

id:{id} a  op:Asset;
        dct:modified "{modified}"^^xsd:dateTime .
"""

OFFER_TEMPLATE = """
{prefixes}

id:{id} a op:Policy,
        odrl:Asset,
        odrl:Offer,
        odrl:Policy ;
    op:policyDescription "This Licence Offer is for the display of a single photograph as 'wallpaper' or similar background on a personal digital device such as a mobile phone, laptop computer or camera roll. The Licence Holder must be an individual (not an organization)."@en ;
    odrl:duty id:{id}1293 ;
    dct:created "2016-03-03T16:28:00"^^xsd:dateTime ;
    dct:modified "2016-03-03T16:29:00"^^xsd:dateTime ;
    odrl:conflict odrl:invalid ;
    odrl:inheritAllowed false ;
    odrl:permission id:{id}7852 ;
    odrl:profile "http://openpermissions.org/ns/op/1.1/"^^xsd:string ;
    odrl:type "offer"^^xsd:string ;
    odrl:uid "{id}"^^xsd:string ;
    odrl:undefined odrl:invalid .

id:{id}f7f6 a odrl:Constraint ;
    odrl:operator odrl:isPartOf ;
    odrl:spatial <http://sws.geonames.org/6295630/> .

id:{id}faff a odrl:Constraint ;
    odrl:height 400 ;
    odrl:operator odrl:lteq ;
    odrl:unit <http://openpermissions.org/ns/opex/1.0/pixel> .

id:{id}99d5 a odrl:Duty,
        odrl:Rule ;
    odrl:action odrl:attribute ;
    odrl:target <http://openpermissions.org/ns/id/fc6ea20a8ce4447f98d1e0b75b506c0e> .

id:{id}7852 a odrl:Permission,
        odrl:Rule ;
    odrl:action odrl:display ;
    odrl:assigner hub:TestDemoPseudoLtd ;
    odrl:constraint id:{id}f7f6,
        id:{id}faff,
        id:{id}6f61c,
        id:{id}07b3 ;
    odrl:duty id:{id}99d5 .

id:{id}1293 a odrl:Duty,
        odrl:Rule ;
    odrl:action odrl:compensate ;
    odrl:assigner hub:TestDemoPseudoLtd ;
    odrl:constraint id:{id}19b0 .

id:{id}4e86 a op:Asset,
        op:AssetSelector,
        odrl:Asset ;
    op:count 1 ;
    op:fromSet id:{id}4e86 ;
    odrl:uid "{id}0928"^^xsd:string .

id:{id}19b0 a odrl:Constraint ;
    odrl:operator odrl:eq ;
    odrl:payAmount 10.0 ;
    odrl:unit <http://cvx.iptc.org/iso4217a/GBP> .

id:{id}f61c a odrl:Constraint ;
    odrl:operator odrl:lteq ;
    odrl:unit <http://openpermissions.org/ns/opex/1.0/pixel> ;
    odrl:width 400 .

id:{id}07b3 a odrl:Constraint ;
    odrl:operator odrl:lteq ;
    odrl:post 1 .

id:{id}6c0e a dc:Text ;
    dc:description "This photograph (c) Test Demo PseudoLtd , all rights reserved."@en .
"""

TESTCO_ASSET_IDTYPE = u'testcopictureid'

COMMON_ASSET_DETAILS = {
    'organisation_id': u'testco',
    'organisation_repo': u'testco repo',
    'resolver_id': u'openpermissions.org',
    'hub_id': u'hub1',
    'source_id_type': u'testcopictureid'
}


@given(u'body is "{attr}"')
def set_context_body(context, attr):
    context.body = getattr(context, attr.replace(' ', '_'))


def generate_offer(offer_id, expiry_date=None, set_id=None):
    date = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    offer_ttl = OFFER_TEMPLATE.format(
        prefixes=COMMON_PREFIXES,
        id=offer_id,
        created_date=date,
        uuid=generate_random_id()
    )
    graph = Graph()
    graph.parse(data=offer_ttl, format='turtle')
    if set_id:
        graph.parse(
            COMMON_PREFIXES + "\n" + OFFER_ASSET_SELECTOR1.format(
                        offer_id=offer_id,
                        set_id=set_id
            )
        )
    if expiry_date:
        triple = (
            URIRef("http://openpermissions.org/ns/id/"+offer_id),
            URIRef("http://openpermissions.org/ns/op/1.1/expires"),
            Literal(expiry_date, datatype=rdflib.XSD.dateTime))
        graph.add(triple)
    offer_xml = graph.serialize(format='json-ld', context=JSON_LD_CONTEXT)
    return offer_xml


def get_repository_id(context):
    try:
        return context.repository['id']
    except AttributeError:
        raise ValueError('repository is not set for the asset')


@given(u'request body is a "{state}" offer with an expiry date of "{expiry_date}"')
@given(u'request body is a "{state}" offer with id "{random_id}"')
@given(u'request body is an "{state}" offer with id "{random_id}"')
@given(u'request body is an "{state}" offer')
@given(u'request body is a "{state}" offer')
def valid_offer(context, state=None, expiry_date=None, random_id=None):
    if not random_id:
        random_id = generate_random_id()

    offer_id = random_id

    if state == "valid":
        context.offer = {'id': offer_id}
        random_offer = generate_offer(offer_id, expiry_date)
        context.body = random_offer
    elif state == "invalid":
        context.body = 'invalid data'



@given(u'request body is an indirect offer for set "{set_id}"')
def valid_offer_set(context, set_id=None):
    offer_id = generate_random_id()
    context.offer = {'id': offer_id}
    context.body = generate_offer(offer_id, None)

@given(u'an "{state}" offer with id "{offer_id}"')
@given(u'a "{state}" offer with id "{offer_id}"')
@given(u'a "{state}" offer')
@given(u'an "{state}" offer')
def add_an_offer(context, state, offer_id=None):
    background = """
    Given the "repository" service
    And the repository "testco repo" belonging to "testco"
    And the "offers" endpoint for the repository
    And the client ID is the "testco" "external" service ID
    And the client has an access token granting "write" access to the repository
    """
    if state == "valid":
        context.clean_execute_steps(u"""{}
        And Header "Content-Type" is "application/ld+json"
        And request body is a "valid" offer
        When I make a "POST" request""".format(background))
        context.offer = {"id": context.response_object['data']['id']}
        if hasattr(context, "offer_ids"):
            context.offer_ids.append(context.response_object['data']['id'])
        check_success(context)
    elif state == "expired":
        context.clean_execute_steps(u"""{}
        And Header "Content-Type" is "application/ld+json"
        And request body is a "valid" offer with an expiry date of "{}"
        When I make a "POST" request""".format(background, "1999-12-31T23:59:59Z"))
        context.offer = {
                         "id": context.response_object['data']['id'],
                        }
        if hasattr(context, "offer_ids"):
            context.offer_ids.append(context.response_object['data']['id'])
        check_success(context)
    elif state == "previous":
        context.clean_execute_steps(u"""{}
        And Header "Content-Type" is "application/ld+json"
        And request body is a "valid" offer with id "011C1C1"
        When I make a "POST" request""".format(background)
        )
        context.offer = {
                         "id": context.response_object['data']['id'],
                         "hub_key": context.response_object['data']['hub_key']
                        }
        if hasattr(context, "offer_ids"):
            context.offer_ids.append(context.response_object['data']['id'])
        check_success(context)
    elif state == "non-existent":
        context.offer = {'id': generate_random_id()}
    else:
        assert False

def add_offer_and_set(context, state, offer_id=None):
    background = """
    Given the "repository" service
    And the repository "testco repo" belonging to "testco"
    And the "offers" endpoint for the repository
    And the client ID is the "testco" "external" service ID
    And the client has an access token granting "write" access to the repository
    """
    set_id = "a"+str(uuid.uuid4())[1:]
    context.clean_execute_steps(u"""{background}
    And Header "Content-Type" is "application/ld+json"
    And request body is an indirect offer for set "{set_id}"
    When I make a "POST" request""".format(background=background, set_id=set_id))
    context.offer = {"id": context.response_object['data']['id']}
    if hasattr(context, "offer_ids"):
        context.offer_ids.append(context.response_object['data']['id'])
    if not hasattr(context, "set_ids"):
        context.set_ids = []
    context.set_ids.append(set_id)
    check_success(context)


@given(u'an agreement for an offer for party "{party_id}"')
def add_an_agreement_for_an_offer(context, party_id):
    """
    Create a new offer and agreement

    party_id can be an arbitrary value
    """
    context.clean_execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

        And a "valid" offer
        And an asset has been added for the given offer
        And the "agreements" endpoint for the repository
        And request body has a key of "offer_id" with the offer id
        And request body has a key of "party_id" with a value of "{party_id}"


       When I make a "POST" request

       Then I should receive a "200" response code
    """.format(party_id=party_id), save_response_data='agreement')




@given(u'an agreement')
def given_an_agreement(context):
    context.clean_execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And an agreement for an offer for party "2357111317"
    """, save_response_data='agreement')


@given(u'a set')
def given_a_set(context):
    context.clean_execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And "testco" may read from the repository
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository
        And the "sets" endpoint for the repository

        When I make a "POST" request

        Then I should receive a "200" response code
    """, save_response_data='set')


@given(u'a group of {number} asset ids')
def step_impl(context, number):
    context.set_asset_ids = [generate_random_id('uuids') for i in range(int(number))]
    graph = Graph()
    asset_ttl = COMMON_PREFIXES
    for entity_id in context.set_asset_ids:
        asset_ttl += MINIMAL_ASSET_TEMPLATE.format(
            id=entity_id,
            modified=isoformat(datetime.utcnow())
        )
    graph.parse(data=asset_ttl, format='turtle')

    asset_xml = graph.serialize(format='xml')
    with context.keep_request_data(), context.keep_attributes('organisation', 'params', 'headers', 'organisation_id'):
        context.reset_request_data()
        context.body = asset_xml
        context.execute_steps(u"""
           Given  the "repository" service
            And the repository "testco repo" belonging to "testco"
            And the client ID is the "testco" "external" service ID
            And the client has an access token granting "write" access to the repository
            And the "assets" endpoint for the repository
            And Header "Content-Type" is "application/xml"
            And Header "Accept" is "application/json"

           When I make a "POST" request with the repository id

           Then I should receive a "200" response code
            And response should have key "status" of 200
            And response header "Content-Type" should be "application/json; charset=UTF-8"
            And response should not have key "errors"
        """)


@given(u'the "set asset" endpoint for the "{obj}" "{attr}" with the asset "{asset_no}"')
def given_a_set(context, obj, attr, asset_no):
    repository_id = get_repository_id(context)
    context.execute_steps(u"""
        Given the "set asset" endpoint
    """)
    resource_id = quote_plus(getattr(context, obj).get(attr))
    context.endpoint = context.endpoint.format(repository_id, resource_id, context.set_asset_ids[int(asset_no)])

@given(u'a set with {nbassets} assets')
def given_a_set_with_assets(context, nbassets):
    context.execute_steps(u"""
       Given a set
        And a group of {} asset ids
        And the "set assets" endpoint of the repository for the "set" "id"
        and parameter "assets" is the set_asset_ids

       When I make a "POST" request

       Then I should receive a "200" response code
        And response should have key "status" of 200
    """.format(nbassets))
    context.params = {}


@given(u'an array of 1 assets as the body')
def use_premade_asset(context):
    body = [
        {
            "source_id_type": context.id_map['source_id_type'],
            "source_id": context.id_map['source_id']
        }
    ]
    context.body = body


def generate_query(number, valid_id=True):
    result = []
    for i in range(number):
        result.append(generate_query_object(valid_id))
    return result


def generate_random_id(keytype="testcoid"):
    uuidv = str(uuid.uuid4()).replace('-', '')
    if keytype == "hub_keyS0":
        return "https://openpermissions.org/s0/hub1/asset/testco/testcoid/%s"%(uuidv)
    else:
        return uuidv


def generate_query_object(valid_id):
    source_id_type = COMMON_ASSET_DETAILS['source_id_type'] if valid_id else u"InvalidIdType"
    return {"source_id_type": source_id_type,
            "source_id": generate_random_id()}


@given(u'an invalid Query objects as the body')
def invalid_objects_as_body(context):
    context.body = "gibberish"


@given(u'"{no_of_lic_offs}" offers have already been onboarded')
def add_offers(context, no_of_lic_offs):
    try:
        no_of_lic_offs = int(no_of_lic_offs)
    except ValueError:
        raise ValueError("Number of offers must be a number")

    context.offer_ids = []

    for _ in range(no_of_lic_offs):
        add_an_offer(context, "valid")
        if context.offer['id'] not in context.offer_ids:
            context.offer_ids.append(context.offer['id'])


@given(u'"{no_of_lic_offs}" offers with sets have already been onboarded')
def add_offer_sets(context, no_of_lic_offs):
    try:
        no_of_lic_offs = int(no_of_lic_offs)
    except ValueError:
        raise ValueError("Number of offers must be a number")

    context.offer_ids = []

    for _ in range(no_of_lic_offs):
        add_offer_and_set(context, "valid")
        if context.offer['id'] not in context.offer_ids:
            context.offer_ids.append(context.offer['id'])


@given(u'body is a "{state}" xml asset')
@given(u'body is an "{state}" xml asset')
@given(u'body is "{state}" an xml asset')
def inject_asset_into_context_body(context, state):
    if state == "valid":
        source_id = generate_random_id()
        entity_ids, asset_ttl = format_common_asset(source_id)
        offer_id = getattr(context, 'offer', {}).get('id')
        offer_ids = [offer_id] if offer_id else []
        context.body = generate_asset_xml(
            offer_ids,
            asset_ttl,
            entity_ids[0]
        )
    elif state == "invalid":
        context.body = """
        <?xml version="1.0" encoding="UTF-8"?>
        <note>
            <p>
                badly formed xml
        </note>
        """
    elif state == "not":
        context.body = "not xml data"


date_format = "%Y-%m-%dT%H:%M:%SZ"


def isoformat(d):
    """
    :param d: a date
    :return: Returns valid iso8601 with timezone dateformat for linked data
    """
    return d.strftime(date_format)

def generate_asset_xml(offer_ids, asset_ttl, entity_id):
    graph = Graph()
    graph.parse(data=asset_ttl, format='turtle')
    for offer_id in offer_ids:
        asset_offer_ttl = ASSET_DIRECT_OFFER_TEMPLATE.format(
            prefixes=COMMON_PREFIXES,
            id=entity_id,
            offer_id=offer_id,
            modified=isoformat(datetime.utcnow())
        )
        graph.parse(data=asset_offer_ttl, format='turtle')

    asset_xml = graph.serialize(format='xml')
    return asset_xml


def generate_indirect_asset_xml(asset_ttl, entity_id, offer_ids=[], set_ids=[]):
    graph = Graph()
    graph.parse(data=asset_ttl, format='turtle')
    for offer_id in offer_ids:
        asset_offer_ttl = ASSET_INDIRECT_OFFER_TEMPLATE.format(
            prefixes=COMMON_PREFIXES,
            id=entity_id,
            offer_id=offer_id,
            set_id=offer_id+"5e4",
            modified=isoformat(datetime.utcnow())
        )

        graph.parse(data=asset_offer_ttl, format='turtle')

    for set_id in set_ids:
        asset_offer_ttl = ASSET_INDIRECT_SET_TEMPLATE.format(
            prefixes=COMMON_PREFIXES,
            id=entity_id,
            set_id=set_id,
            modified=isoformat(datetime.utcnow())
        )

        graph.parse(data=asset_offer_ttl, format='turtle')

    asset_xml = graph.serialize(format='xml')
    return asset_xml


def format_common_asset(source_id):
    bnode_id = generate_random_id()

    if COMMON_ASSET_DETAILS['source_id_type'] != 'hub_key':
        entity_ids = [generate_random_id()]
    else:
        entity_ids = [source_id]

    asset = ASSET_TEMPLATE.format(
        prefixes=COMMON_PREFIXES,
        id=entity_ids[0],
        source_id_type=COMMON_ASSET_DETAILS['source_id_type'],
        source_id=source_id,
        bnode_id=bnode_id,
        timestamp=datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    )
    return (entity_ids, asset)


@given(u'an {asset} has been added for the given offer')
@clean_step
def add_asset_for_offers(context, asset):
    assert hasattr(context, 'repository'), 'no repository set in the context'
    if hasattr(context, 'offer_ids'):
        offer_ids = context.offer_ids
    elif hasattr(context, 'offer'):
        offer_ids = [context.offer['id']]
    else:
        raise KeyError("Missing offer ID(s) for asset")

    source_id = generate_random_id()
    entity_ids, asset_ttl = format_common_asset(source_id)
    if asset == "asset":
        asset_xml = generate_asset_xml(offer_ids, asset_ttl, entity_ids[0])
    if asset == "indirect asset":
        asset_xml = generate_indirect_asset_xml(asset_ttl, entity_ids[0], offer_ids=offer_ids)

    context.body = asset_xml
    hub_key = TEMPLATE_HUBKEY.format(
        repo_id=context.repository['id'],
        id_type=asset,
        id=unquote_plus(entity_ids[0].encode())
    )
    hub_key0 = TEMPLATE_HUBKEY_V0.format(
        entity_type = 'asset',
        org_id = COMMON_ASSET_DETAILS["organisation_id"],
        source_id_type = COMMON_ASSET_DETAILS['source_id_type'],
        source_id=source_id
    )
    context.id_map = {
        'source_id_type': COMMON_ASSET_DETAILS['source_id_type'],
        'source_id': source_id,
        'entity_id': unquote_plus(entity_ids[0].encode()),
        'hub_key': hub_key,
        'hub_key1': '/'.join(hub_key.split('/')[3:]),
        'hub_key0': '/'.join(hub_key0.split('/')[3:])
    }
    context.asset = {'id': entity_ids[0]}

    context.execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

        And the "assets" endpoint
        And Header "Content-Type" is "application/xml"
        And Header "Accept" is "application/json"
        When I make a "POST" request with the repository id
    """)
    check_success(context)


def check_success(context):
    if context.response.status_code != 200:
        status_code = context.response.status_code
        error = context.response_object.get("errors", [{}])[0]
        source = error.get('source', 'not set').strip()
        error_msg = error.get('message', 'not set').strip()
        msg = '\n\n========================== CAPTURED ERROR ========================='
        msg += "\nStatus code: {}\nSource: {}\nError message: {}\n".format(
            status_code,
            source,
            error_msg
        )
        raise AssertionError(msg)


@given(u'an asset not in the repository')
def a_new_asset_not_in_repo(context):
    source_id = generate_random_id()
    context.id_map = {
        'source_id_type': COMMON_ASSET_DETAILS['source_id_type'],
        'source_id': source_id
    }


@given(u'a body of {count} generated valid ids')
def add_valid_ids_to_body(context, count):
    context.body = {
        'ids': [{
            'source_id_type': COMMON_ASSET_DETAILS['source_id_type'],
            'source_id': generate_random_id()}
            for _ in range(int(count))
        ]
    }


@given(u'a body of {count} generated invalid ids')
def add_invalid_ids_to_body(context, count):
    ids = []
    for index in range(int(count)):
        if index % 2:
            ids.append({
                'source_id_type': COMMON_ASSET_DETAILS['source_id_type']
            })
        else:
            ids.append({'source_id': generate_random_id()})
    context.body = {'ids': ids}


@given(u'a body of {count} generated invalid id types')
def add_invalid_types_to_body(context, count):
    context.body = {'ids': [{'source_id_type': 'InvalidPictureIDType',
                             'source_id': generate_random_id()}
                            for _ in range(int(count))]}


@given(u'the "{resource}" endpoint of the repository for the "{obj}" "{attr}"')
def endpoint_of_the_repository(context, resource, obj, attr):
    repository_id = get_repository_id(context)
    context.execute_steps(u"""
        Given the "{}" endpoint
    """.format(resource))
    resource_id = quote_plus(getattr(context, obj).get(attr))
    context.endpoint = context.endpoint.format(repository_id, resource_id)


@given(u'the "{resource}" endpoint of the repository for an invalid {entity_type}')
def repository_enpoint_invalid_entity(context, resource, entity_type):
    repository_id = get_repository_id(context)
    context.execute_steps(u"""
        Given the "{}" endpoint
    """.format(resource))
    context.endpoint = context.endpoint.format(repository_id, 'a' * 32)


@given(u'the additional IDs endpoint for the new asset')
def endpoint_for_asset(context):
    repository_id = get_repository_id(context)
    context.execute_steps(u"""
        Given the "asset ids" endpoint
    """)
    entity_id = context.id_map['entity_id']
    context.endpoint = context.endpoint.format(quote_plus(repository_id), quote_plus(entity_id))


@given(u'the additional IDs endpoint for an illegal asset')
def endpoint_for_illegal_asset(context):
    repository_id = get_repository_id(context)
    context.execute_steps(u"""
        Given the "asset ids" endpoint
    """)
    entity_id = str(uuid.uuid4()).replace('-',  '')
    context.endpoint = context.endpoint.format(quote_plus(repository_id), quote_plus(entity_id))


@when(u'I query the "{service}" service for the asset')
def query_for_asset(context, service):
    assert service == context.service_name, (
        'expected context.service_name = {} got {}'.format(
                service, context.service_name)
    )
    id_map = context.id_map
    query_an_asset(context, id_map['source_id_type'], id_map['source_id'])


@when(u'I query the "{service}" service for the asset using a schema 0 hub key')
def query_for_asset(context, service):
    assert service == context.service_name, (
        'expected context.service_name = {} got {}'.format(
                service, context.service_name)
    )
    id_map = context.id_map
    hub_key = 'https://openpermissions.org/s0/hub1/asset/maryevans/{}/{}'.format(
        id_map['source_id_type'],
        id_map['source_id'])
    query_an_asset(context, 'hub_key', hub_key)


@when(u'I bulk query the "{service}" service for the asset')
def query_for_asset(context, service):
    assert service == context.service_name, (
        'expected context.service_name = {} got {}'.format(
                service, context.service_name)
    )
    id_map = context.id_map
    body = [
        {
            'source_id_type': id_map['source_id_type'],
            'source_id': id_map['source_id']
        }
    ]
    query_by_source_id_and_type(context, body)


@when(u'I bulk query the "{service}" service for the asset using a schema 0 hub key')
def query_for_asset(context, service):
    assert service == context.service_name, (
        'expected context.service_name = {} got {}'.format(
                service, context.service_name)
    )
    id_map = context.id_map
    hub_key = 'https://openpermissions.org/s0/hub1/asset/maryevans/{}/{}'.format(
            id_map['source_id_type'],
            id_map['source_id'])
    body = [
        {
            'source_id_type': 'hub_key',
            'source_id': hub_key
        }
    ]
    query_by_source_id_and_type(context, body)


@when(u'I query the "{service}" service for the asset together with another asset')
def query_for_multi_assets(context, service):
    assert service == context.service_name, (
        'expected context.service_name = {} got {}'.format(
            service, context.service_name)
    )
    id_map = context.id_map
    body = [
        {
            'source_id_type': id_map['source_id_type'],
            'source_id': id_map['source_id']
        }
    ]
    body.append(generate_query_object(True))
    query_by_source_id_and_type(context, body)


@clean_step
def query_an_asset(context, source_id_type, source_id):
    context.execute_steps(u"""
    Given Header "Content-Type" is "application/json"
      And Header "Accept" is "application/json"
      And parameter "source_id_type" is "{}"
      And parameter "source_id" is "{}"
     When I make a "GET" request
    """.format(source_id_type, source_id))


@clean_step
def query_by_source_id_and_type(context, body):
    context.body = body
    context.execute_steps(u"""
    Given Header "Content-Type" is "application/json"
      And Header "Accept" is "application/json"
     When I make a "POST" request
    """)


@given(u'an array of "{number}" "{query_type}" Query objects as the body')
def step_impl(context, number, query_type):
    num = int(number)
    if query_type == "no result":
        context.body = generate_query(context, num)
    elif query_type == "resulting":
        context.body = get_query(context, num)
    elif query_type == "mixed":
        assert num >= 2
        div, mod = divmod(num, 2)
        context.body = generate_query(div + mod)
        context.body += get_query(context, div)
    elif query_type == "invalid id type":
        context.body = generate_query(num, False)
    else:
        assert False


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


def get_query(context, number):
    result = []
    for i in range(number):
        result.append(get_query_object(context))
    return result


def get_query_object(context):
    id_map = context.id_map
    body = random.choice([
        {
            'source_id_type': id_map['source_id_type'],
            'source_id': id_map['source_id']
        }
    ])

    # FIXME(CHUB-2320): get_query_object shall ideally return different assets.
    # Currently tests generate only one asset - obviously to do proper
    # tests we will need more than one asset here.

    return body

