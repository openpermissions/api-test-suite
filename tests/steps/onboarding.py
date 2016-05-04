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
from six.moves.urllib.parse import quote
import re

CSV_KEYS = [
    'source_id_types',
    'source_ids',
    'offer_ids',
    'description'
]

JSON_KEYS = [
    'source_id_type',
    'source_id',
    'offer_ids',
    'description'
]

VALUES = [
    'testcopictureid',
    '{format}-{row}-{total}',
    ('https://https://openpermissions/s0/hub1/offer/chub/1~https://https://openpermissions/s0/hub1/offer/chub/2~'
     'https://https://openpermissions/s0/hub1/offer/chub/3~https://https://openpermissions/s0/hub1/offer/chub/4'),
    'This is description {row}'
]

CSV_MAP = dict(zip(CSV_KEYS, VALUES))


def format_item(item, data_format, row, total):
    return item.format(format=data_format, row=row, total=total)


def csv_rows(num_rows, csv_map=None):
    if csv_map is None:
        csv_map = CSV_MAP

    row_template = ','.join(csv_map.values())
    rows = '\n'.join(format_item(row_template, 'csv', row, num_rows)
                     for row in range(num_rows))

    return rows


def create_csv(num_rows, csv_map=None):
    if csv_map is None:
        csv_map = CSV_MAP

    headers = ','.join(csv_map.keys())

    return headers + '\n' + csv_rows(num_rows, csv_map)


def create_json(num_objects):
    objects = []
    for i in xrange(int(num_objects)):
        item = {k: format_item(v, 'json', i, num_objects)
                for k, v in zip(JSON_KEYS, VALUES)}
        item['offer_ids'] = item['offer_ids'].split('~')
        item['source_ids'] = [
            {'source_id': item['source_id'],
             'source_id_type': item['source_id_type']}
        ]
        del item['source_id']
        del item['source_id_type']
        objects.append(item)
    return objects


@given('body is a JSON array with {n} objects')
def json_data(context, n):
    context.body = create_json(int(n))


@given('body is an invalid JSON array with {n} objects')
def invalid_json_data(context, n):
    objects = create_json(int(n))
    for item in objects:
        del item['source_id']
    context.body = objects


@given('body is csv data with {n} rows of data')
def csv_data(context, n):
    context.body = create_csv(int(n)).encode('utf-8')


@given('body is csv data with no header')
def csv_no_header(context):
    context.body = csv_rows(2).encode('utf-8')


@given('body is csv data with incomplete header')
def csv_incomplete_header(context):
    context.body = create_csv(2, dict(CSV_MAP.items()[1:])).encode('utf-8')


@given('body is csv data with {n} invalid rows')
def csv_invalid_rows(context, n):
    data = create_csv(int(n), dict(CSV_MAP.items()[1:]))
    data = CSV_MAP.keys()[0] + ',' + data

    context.body = data.encode('utf-8')


@given('body is csv data that exceeds the maximum allowable size')
def csv_too_large(context):
    context.body = csv_rows(15000).encode('utf-8')


@given('body is JSON data that exceeds the maximum allowable size')
def json_too_large(context):
    context.body = create_json(15000)


@then('I should receive {n} source identifiers to hub keys')
def should_receive_identifiers(context, n):
    n = int(n)
    json_response = context.response.json()
    assets = json_response.get('data')

    assert assets, 'Expected "assets" in response'

    msg = 'Expected {} assets, received {}'.format(n, len(assets))
    assert len(assets) == n, msg

    for asset in assets:
        assert asset.get('entity_id'), 'Expected an entity_id'

        entity_type = 'asset'
        msg = 'Expected source_id_type == {}, got {}'.format(
            entity_type, asset['entity_type'])
        assert asset['entity_type'] == entity_type, msg

        hub_key_template = "https://openpermissions.org/s1/hub1/{}/{}/".format(
            context.repository['id'], entity_type)

        expected_hub_key = re.compile(hub_key_template + '[0-9a-f]{32}')
        msg = 'Expected hub_id to match {}, got {}'.format(expected_hub_key, asset['hub_key'])

        match = expected_hub_key.match(asset['hub_key'])
        assert match, msg


@then('I should receive errors in the response')
def should_receive_error_message(context):
    json_response = context.response.json()

    assert 'errors' in json_response, 'Expected errors'
    assert len(json_response['errors']) >= 1, 'Expected at least one error'


@then('I should receive {n} errors in the response')
def should_receive_n_error_messages(context, n):
    n = int(n)
    json_response = context.response.json()

    assert 'errors' in json_response, 'Expected errors'

    num_errors = len(json_response['errors'])
    assert num_errors == n, 'Expected {} errors, got {}'.format(n, num_errors)
