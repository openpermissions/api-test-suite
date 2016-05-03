# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

from koi import CA_CRT
from chub.api import API_VERSION

SERVICES = {
    'identity': 'https://localhost:8001/{}/identity'.format(API_VERSION),
    'index': 'https://localhost:8002/{}/index'.format(API_VERSION),
    'onboarding': 'https://localhost:8003/{}/onboarding'.format(API_VERSION),
    'transformation': 'https://localhost:8005/{}/transformation'.format(API_VERSION),
    'accounts': 'https://localhost:8006/{}/accounts'.format(API_VERSION),
    'auth': 'https://localhost:8007/{}/auth'.format(API_VERSION),
    'template': 'https://localhost:9000/{}/template'.format(API_VERSION),
    'query': 'https://localhost:8008/{}/query'.format(API_VERSION)
}

# reason this is such a high value is that if testing a fresh setup
# the first run is slower
DEFAULT_REQUEST_TIMEOUT = (3.0, 60.0)

R2RML_MAPPING_URLS = {
    'json': 'https://raw.githubusercontent.com/openpermissions/r2rml-mappings/3.0.0/mappings/digicat0_json.ttl',
    'csv': 'https://raw.githubusercontent.com/openpermissions/r2rml-mappings/3.0.0/mappings/digicat0_csv.ttl'
}

test_org = 'hogwarts'
