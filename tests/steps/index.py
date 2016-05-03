# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#

import uuid
import datetime
from behave import given, then
from repository import generate_random_id, check_success
from environment import clean_step
from time import sleep

NS = {
    "chubindex": "<http://digicat.io/ns/chubindex/1.0/>",
    "op": "<http://openpermissions.org/ns/op/1.1/>",
    "hub": "<http://openpermissions.org/ns/hub/>",
    "dc": "<http://purl.org/dc/elements/1.1/>",
    "dct": "<http://purl.org/dc/terms/>",
    "odrl": "<http://www.w3.org/ns/odrl/2/>",
    "rdf": "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
    "rdfs": "<http://www.w3.org/2000/01/rdf-schema#>",
    "xml": "<http://www.w3.org/XML/1998/namespace>",
    "xsd": "<http://www.w3.org/2001/XMLSchema#>"
}


@given(u'the asset has been indexed')
def asset_is_indexed(context):
    # Checks the index service for asset every 5 seconds for a minute.
    # Stops when asset is found or returns an assertion error if
    # still not found after 1 minute
    time_elapsed = 0
    with context.keep_request_data():
        while (time_elapsed < 60):
            context.clean_execute_steps(u"""
            Given the client ID is the "testco" "external" service ID
            And the client has an access token granting "read" access to the "hogwarts" "index" service
            Given the "index" service
            And the "/entity-types/asset/id-types/{source_id_type}/ids/{source_id}/repositories" endpoint
            And Header "Accept" is "application/json"

            When I make a "GET" request""".format(**context.id_map))
            if context.response.status_code == 200:
                return
            sleep(5)
            time_elapsed += 5

        raise AssertionError("Asset {source_id_type}:{source_id} has not been indexed after 60 seconds. "
                             "Has something gone wrong?".format(**context.id_map))


@given(u'the body is an array containing the following asset ID types')
def body_with_known_ids(context):
    ids = {
        'hub_key': context.id_map['hub_key'],
        'testcopictureid': context.id_map['source_id']
    }
    data = [{'source_id': ids[i['source_id_type']], 'source_id_type': i['source_id_type']}
            for i in context.table]
    context.body = data


@given(u'the body is an array containing an unindexed id')
def body_with_unknown_ids(context):
    context.body = [{'source_id': str(uuid.uuid4()), 'source_id_type': 'testcopictureid'}]


@then(u'each object in the array has a "{name}" array of size "{size}"')
def check_object_array_of_size(context, name, size):
    data = context.response_object['data']

    for item in data:
        assert name in item
        assert len(item[name]) == int(size)


@then(u'each element of "{name}" has attributes "{fields}"')
def check_object_array(context, name, fields):
    data = context.response_object
    for n in name.split("/"):
        data = data[n]

    for item in data:
        for field in fields.split(","):
            field = field.split("/")
            citem = item
            for n in field[:-1]:
                citem = citem[n]

            assert field[-1] in citem


#
#    Let's assume we have the following graph linking hub_keys and "source ids"
#           repo1 repo2
#            |     |
#           HK1  HK2  HK3 --\    /-- HK4
#          / | \  |  /   \   \  /    / |
#         /  |  \ | /     \   s3    /  |
#        s1 s1b  s2        ---s4---/   s5

R1 = "repo1"
R2 = "repo2"
R3 = "repo3"
R4 = "repo4"
HK1 = "https://openpermissions.org/s1/hub1/{repo_id}/asset/da211f3a033111e6b418acbc32a8c615"
HK2 = "https://openpermissions.org/s1/hub1/{repo_id}/asset/e02cee05033111e6a40aacbc32a8c615"
HK3 = "https://openpermissions.org/s1/hub1/{repo_id}/asset/f715cd2b033111e689b3acbc32a8c615"
HK4 = "https://openpermissions.org/s1/hub1/{repo_id}/asset/f7777573033111e6b459acbc32a8c615"
S1 = {"source_id_type": "my_id_type", "source_id": "s1"}
S1B = {"source_id_type": "other_id_type", "source_id": "s1b"}
S2 = {"source_id_type": "foo_id_type", "source_id": "s2"}
S3 = {"source_id_type": "bar_id_type", "source_id": "s3"}
S4 = {"source_id_type": "bing_id_type", "source_id": "s4"}
S5 = {"source_id_type": "bong_id_type", "source_id": "s5"}


def dict_merge(d1, d2):
    r = {}
    r.update(d1)
    r.update(d2)
    return r


DATA_TEST_RELATED = [
    # HK1
    dict_merge(S1, {"entity_uri": HK1}),
    dict_merge(S1B, {"entity_uri": HK1}),
    dict_merge(S2, {"entity_uri": HK1}),
    # HK2
    dict_merge(S2, {"entity_uri": HK2}),
    # HK3
    dict_merge(S2, {"entity_uri": HK3}),
    dict_merge(S3, {"entity_uri": HK3}),
    dict_merge(S4, {"entity_uri": HK3}),
    # HK 4
    dict_merge(S3, {"entity_uri": HK4}),
    dict_merge(S4, {"entity_uri": HK4}),
    dict_merge(S5, {"entity_uri": HK4})
]


REPO = {
    HK1: R1,
    HK2: R2,
    HK3: R3,
    HK4: R4
}


TURTLE_PREFIX = "\n".join(map(lambda i: "@prefix %s: %s." % i, NS.items()))


@given(u'related asset have been added for the given offer')
@clean_step
def add_related_assets_for_offers(context):
    assert hasattr(context, 'repository'), 'no repository set in the context'
    # if hasattr(context, 'offer_ids'):
    #     offer_ids = context.offer_ids
    # elif hasattr(context, 'offer'):
    #     offer_ids = [context.offer['id']]
    # else:
    #     raise KeyError("Missing offer ID(s) for asset")

    asset_data = TURTLE_PREFIX + "\n"

    for i in [HK1, HK2, HK3, HK4]:
        asset_data += """
        <{id}> a op:Asset .
        <{id}> dct:description "description text" .
        <{id}> dct:modified "{timestamp}Z"^^xsd:dateTime .
       """.format(timestamp=datetime.datetime.utcnow().isoformat(),
                  id=i.format(repo_id=context.repository['id']))

    for i in DATA_TEST_RELATED:
        asset_data += """
        <{id}> op:alsoIdentifiedBy _:{uuid} .
        _:{uuid} a op:Id .
        _:{uuid} op:id_type hub:{source_id_type} .
        _:{uuid} op:value "{source_id}"^^xsd:string .
""".format(source_id_type=i["source_id_type"],
           source_id=i["source_id"],
           uuid=generate_random_id(),
           id=i["entity_uri"].format(repo_id=context.repository['id']))

    context.id_map = {
        'S1': (S1['source_id_type'], S1['source_id']),
        'S1b': (S1B['source_id_type'], S1B['source_id']),
        'S2': (S2['source_id_type'], S2['source_id']),
        'S3': (S3['source_id_type'], S3['source_id']),
        'S4': (S4['source_id_type'], S4['source_id']),
        'S5': (S5['source_id_type'], S5['source_id']),
        'HK1': ('hub_key', HK1.format(repo_id=context.repository['id'])),
        'HK2': ('hub_key', HK2.format(repo_id=context.repository['id'])),
        'HK3': ('hub_key', HK3.format(repo_id=context.repository['id'])),
        'HK4': ('hub_key', HK4.format(repo_id=context.repository['id'])),
    }

    context.body = asset_data

    context.execute_steps(u"""
      Given the "repository" service
        And the repository "testco repo" belonging to "testco"
        And the client ID is the "testco" "external" service ID
        And the client has an access token granting "write" access to the repository

        And the "assets" endpoint
        And Header "Content-Type" is "text/rdf+n3"
        And Header "Accept" is "application/json"
       When I make a "POST" request with the repository id
    """)
    check_success(context)
