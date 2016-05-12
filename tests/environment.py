# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# 
"""
Python Behave configuration file

"""
import functools
import os
import json
import urlparse
from collections import defaultdict, deque
from contextlib import contextmanager
from copy import deepcopy

import requests
from chub import API
from chub.api import API_VERSION

import config


def default_request_data():
    """Default request data
    """
    defaults = {
        'base_url': None,
        'service_name': None,
        'endpoint_name': None,
        'endpoint': None,
        'params': {},
        'body': None,
        'headers': {}
    }
    return ((k, v) for k, v in defaults.iteritems())


class NotExists(object):
    pass


def preserve_attributes(obj, attributes):
    attr_to_value = {attr: deepcopy(getattr(obj, attr, NotExists()))
                     for attr in attributes}
    return attr_to_value


def restore_attributes(obj, attr_to_value):
    for attr, value in attr_to_value.items():
        if isinstance(value, NotExists):
            try:
                delattr(obj, attr)
            except AttributeError:
                pass
        else:
            setattr(obj, attr, value)


@contextmanager
def keep_request_data(context):
    """Context manager for keeping the original
    request data.
    """
    attr_to_value = preserve_attributes(
        context, [k for k, _ in default_request_data()])
    yield
    restore_attributes(context, attr_to_value)


@contextmanager
def keep_attributes(context, *attributes):
    """
    a decorator to keep a copy of a list of attributes of the context before
    execute_steps and put the value back aftwards
    """
    attr_to_value = preserve_attributes(context, attributes)
    yield
    restore_attributes(context, attr_to_value)


def clean_step(step_impl):
    """
    a decorator for a step definition which keeps
    the original request data
    """
    @functools.wraps(step_impl)
    def wrapped(context, *args, **kwargs):
        with keep_request_data(context):
            returned = step_impl(context, *args, **kwargs)
        return returned
    return wrapped


def reset_request_data(context):
    """Copy the data to different keys and reset the value to default.
    subsequent steps
    """
    for name, default in default_request_data():
        setattr(context, name, default)


def clean_execute_steps(context, steps_text, save_response_data=None):
    """Execute steps with the keep_request_data context
    manager.

    Useful for calling execute_steps during request build up.

    :param context: the context object
    :param steps_text: the steps to be expecuted
    :param save_respones_data: (optional) context attribute name which will be
        assigned the response object's data
    """
    with keep_request_data(context):
        context.reset_request_data()
        context.execute_steps(steps_text)
        if save_response_data:
            setattr(context, save_response_data,
                    context.response_object.get('data'))


def make_session(verify):
    sess = requests.Session()
    sess.verify = verify
    return sess


def make_keychain():
    keychain = {
        'CA_CRT': config.CA_CRT
    }
    key_dir = os.path.join(os.path.dirname(__file__), 'steps/data/')
    keys = next(os.walk(key_dir))[2]
    for key in keys:
        keychain[key] = os.path.join(key_dir, key)
    return keychain


def set_services(context):
    context.organisation_services = defaultdict(lambda: defaultdict(deque))
    context.services = config.SERVICES.copy()

    sess = make_session(config.CA_CRT)
    token = sess.post(
        '{}/login'.format(config.SERVICES['accounts']),
        data=json.dumps({'email': 'opp@example.com',
                         'password': 'password'})
    ).json()['data']['token']
    registered_services = sess.get(
        '{}/services?organisation_id={}'.format(
            config.SERVICES['accounts'], config.test_org),
        headers={'Authorization': token}).json()['data']

    repos = []

    for service in registered_services:
        service_type = service['service_type']
        context.organisation_services[config.test_org][service_type].append(service)

        if service_type == 'repository':
            repos.append(service)

    set_repository_services(context, repos)


def set_repository_services(context, repositories):
    for repo in repositories:
        context.services[repo['name']] = \
            '{}/{}/repository'.format(repo['location'], API_VERSION)
    # TODO THE REPOSITORY is the term used before
    # we have multiple repositories as default
    # the term needs updating and we should assume
    # the new default of at least two repositories
    context.the_repository = repositories[0]
    context.repository_services = repositories
    context.services['repository'] = \
        '{}/{}/repository'.format(repositories[0]['location'], API_VERSION)


def before_scenario(context, scenario):
    context.keychain = make_keychain()
    context.http_client = make_session(context.keychain['CA_CRT'])
    context.keep_request_data = keep_request_data.__get__(context)
    context.reset_request_data = reset_request_data.__get__(context)
    context.clean_execute_steps = clean_execute_steps.__get__(context)
    context.reset_request_data()
    context.keep_attributes = keep_attributes.__get__(context)


def before_all(context):
    """
    Executes the code before all the tests are run
    """
    set_services(context)
    context.api = {}
    context.repositories = {}

    for service, location in context.services.items():
        url = urlparse.urlparse(location)
        api = API(url.scheme + '://' + url.netloc, async=False)
        try:
            context.api[service] = getattr(api, url.path.split('/')[2])
        except:
            context.api[service] = getattr(api, service)
