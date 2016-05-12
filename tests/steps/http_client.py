# -*- coding: utf-8 -*-
# Copyright 2016 Open Permissions Platform Coalition
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

"""
an http client driven by behave
"""
from __future__ import unicode_literals
import os
import json
import uuid

from behave import step, then, register_type
from jsonpointer import resolve_pointer

from config import DEFAULT_REQUEST_TIMEOUT


JSON_TYPE = 'application/json'


def parse_boolean(text):
    if text.lower() == 'true':
        return True
    elif text.lower() == 'false':
        return False
    raise ValueError('Expect True or False, got {}'.format(text))


register_type(boolean=parse_boolean)


def options_request(context, url):
    context.response = context.http_client.options(
        url, headers=context.headers)


def get_request(context, url):  # todo : lots
    data = context.params or None
    kwargs = {
        'params': data,
        'headers': context.headers,
        'timeout': DEFAULT_REQUEST_TIMEOUT  # todo: load from context
    }

    if 'Authorization' not in context.headers and getattr(context, 'auth', None):
        kwargs['auth'] = context.auth

    kwargs['allow_redirects'] = False
    context.response = context.http_client.get(url, **kwargs)
    try:
        context.response_object = context.response.json()
    except:
        pass


def delete_request(context, url):
    context.response = context.http_client.delete(url, headers=context.headers)
    context.response_object = context.response.json()


def _put_post_data(context):
    result = {
        'headers': context.headers,
        'timeout': DEFAULT_REQUEST_TIMEOUT  # todo: load from context
    }

    # TODO this line is evil! source of many bugs.
    data = context.body or context.params
    if (JSON_TYPE in context.headers.get('Content-Type', JSON_TYPE) and
            not isinstance(data, basestring)):
        data = json.dumps(data)
    if data:
        result['data'] = data

    if 'Authorization' not in context.headers and getattr(context, 'auth', None):
        result['auth'] = context.auth

    return result


def post_request(context, url):
    kwargs = _put_post_data(context)
    context.response = context.http_client.post(url, **kwargs)
    context.response_object = context.response.json()


def put_request(context, url):
    kwargs = _put_post_data(context)

    context.response = context.http_client.put(url, **kwargs)
    context.response_object = context.response.json()


def request(method, context, url):
    mapping = {
        "POST": post_request,
        "PUT": put_request,
        "GET": get_request,
        "DELETE": delete_request,
        "OPTIONS": options_request
    }
    return mapping[method](context, url)


@step('a clean parameter set')
def reset_parameters(context):
    context.params = {}


@step('parameter "{param_name}" is "{param_value}"')
@step('parameter "{param_name}" is integer "{param_value:d}"')
@step('parameter "{param_name}" is boolean "{param_value:boolean}"')
def typed_value(context, param_name, param_value):
    context.params[param_name] = param_value


@step('parameter "{parameter}" is the {obj} {attr}')
def parameter_is_object_attribute(context, parameter, obj, attr):
    context.params[parameter] = getattr(context, obj)[attr]


@step('parameter "{parameter}" is the {attr}')
def parameter_is_context_attribute(context, parameter, attr):
    context.params[parameter] = getattr(context, attr)


@step('parameter "{param_name}" is array "{array_values}"')
def param_is_array(context, param_name, array_values):
    context.params[param_name] = array_values.split(',')


@step('{item} "{value}" is left out')
def parameter_left_out(context, item, value):
    assert item in ['parameter', 'Header']
    if item == 'parameter':
        del context.params[value]
    elif item == 'Header':
        del context.headers[value]


@step('the {attr} "{key}" is "{value}"')
def set_context_attribute(context, attr, key, value):
    if not hasattr(context, attr):
        setattr(context, attr, {key: value})
    else:
        getattr(context, attr)[key] = value


@step('request body is the content of file "{file_name}"')
def body_content_of_file(context, file_name):
    filepath = os.path.join(
        os.path.dirname(__file__),
        '../fixtures',
        file_name)
    with open(filepath, 'rb') as f:
        context.body = f.read()


@step('Header "{header_name}" is empty')
def header_is_empty(context, header_name):
    if header_name in context.headers:
        del context.headers[header_name]


@step('Header "{header_name}" is "{header_value}"')
def header_is_value(context, header_name, header_value):
    context.headers[header_name] = header_value


@then('response header "{header_name}" should be "{header_value}"')
def check_header_value(context, header_name, header_value):
    received_value = context.response.headers[header_name]
    msg = 'Expected {}, received {}'.format(header_value, received_value)
    assert received_value == header_value, msg


@then('I should receive a "{response_code}" response code')
def check_response_code(context, response_code):
    status_code = context.response.status_code
    msg = 'Expected {} status code, but got {}. Content: {}'.format(
        response_code, status_code, context.response.content)
    assert status_code == int(response_code), msg


@then('I should not receive a "{response_code}" response code')
def check_not_response_code(context, response_code):
    status_code = context.response.status_code
    msg = 'Did not Expect {} status code. Content: {}'.format(
        response_code, context.response.content)
    assert status_code != int(response_code), msg


@then('a "{object_name}" object with "{attribute_name}" of "{attribute_value}"')
@then('response "{object_name}" should be an object with "{attribute_name}" of value "{attribute_value}"')
def check_obj_value(context, object_name, attribute_name, attribute_value):
    obj = context.response_object[object_name]
    real_value = obj[attribute_name]
    msg = 'expected {!r} got {!r}'.format(attribute_value, real_value)
    assert real_value == attribute_value, msg


@then('response "{object_name}" should be an object with "{attribute_name}"')
@then('response "{object_name}" should be an object with "{attribute_name}" of type "{attribute_type}"')
def data_has_attr_value(context, object_name, attribute_name, attribute_type=None):
    types_mapper = {'string': basestring, 'dictionary': dict}
    obj = context.response_object[object_name]
    assert attribute_name in obj
    if attribute_type:
        attribute_type = types_mapper.get(attribute_type) or eval(attribute_type)
        assert isinstance(obj[attribute_name], attribute_type)


@then('a "{object_name}" object without "{attribute_name}"')
@then('response "{object_name}" should be an object without "{attribute_name}"')
def response_has_attr_with_attr(context, object_name, attribute_name):
    obj = context.response_object[object_name]
    assert attribute_name not in obj


@then('response "{object_name}" should be an object with "{attribute_name}" of value True')
def check_obj_value_true(context, object_name, attribute_name):
    obj = context.response_object[object_name]
    assert obj[attribute_name] is True


@then('response "{object_name}" should be an object with "{attribute_name}" of value False')
def check_obj_value_false(context, object_name, attribute_name):
    obj = context.response_object[object_name]
    assert obj[attribute_name] is False


@then('a "{object_name}" object with "{attribute_name}" of {obj} {attr}')
@then('response "{object_name}" should be an object with "{attribute_name}" of the {obj} {attr}')
def obj_has_attr(context, object_name, attribute_name, obj, attr):
    check_obj_value(context, object_name, attribute_name, getattr(context, obj)[attr])


@then('response "{object_name}" should be an object with "{attr_name}" same as the submitted value')
def object_attr_matching_param(context, object_name, attr_name):
    obj = context.response_object[object_name]
    assert obj[attr_name] == context.params[attr_name]


@then('an object with "{attribute_name}" of "{attribute_value}"')
def obj_with_attr_of_value(context, attribute_name, attribute_value):
    assert str(context.response_object[attribute_name]) == attribute_value


@then('response should have key "{attribute_name}" of {attribute_value}')
def obj_has_integer(context, attribute_name, attribute_value):
    assert context.response_object[attribute_name] == eval(attribute_value)


@then('an object with "{attribute_name}" of type "{attribute_type}"')
def then_attr_type(context, attribute_name, attribute_type):
    assert isinstance(
        context.response_object[attribute_name],
        eval(attribute_type))


@then('response should have key "{attribute_name}"')
@then('an object with "{attribute_name}"')
def object_with_attr(context, attribute_name):
    assert attribute_name in context.response_object


@then('an object without "{attribute_name}"')
@then('response should not have key "{attribute_name}"')
def object_without_attr(context, attribute_name):
    assert attribute_name not in context.response_object


@then('the response should contain "{attribute_name}" of type "{attribute_type}"')
def response_attr_of_type(context, attribute_name, attribute_type):
    types_mapper = {"string": basestring, "dictionary": dict}

    assert context.response_object[attribute_name]
    assert isinstance(context.response_object[attribute_name],
                      types_mapper[attribute_type])


@then('response "{attribute_name}" should be a "{attribute_type}"')
@then('response "{attribute_name}" should be a "{attribute_type}" with keys "{keys}"')
@then('response "{attribute_name}" should be a "{attribute_type}" with key "{keys}"')
def obj_has_attr_of_type(context, attribute_name, attribute_type, keys=None):
    types_mapper = {"string": basestring, "dictionary": dict}

    assert context.response_object[attribute_name]
    type_check = types_mapper[attribute_type]
    # check type of each item in array/list
    item = context.response_object[attribute_name]
    assert isinstance(item, type_check)
    if keys:
        for key in keys.split():
            assert item.get(key) is not None


@then('an object with array "{attribute_name}" of type "{attribute_type}"')
@then('an object with array "{attribute_name}" of type "{attribute_type}" with key "{keys}"')
@then('an object with array "{attribute_name}" of type "{attribute_type}" with keys "{keys}"')
@then('response "{attribute_name}" should be an array of type "{attribute_type}"')
@then('response "{attribute_name}" should be an array of type "{attribute_type}" with keys "{keys}"')
@then('response "{attribute_name}" should be an array of type "{attribute_type}" with key "{keys}"')
def obj_has_attr_of_type(context, attribute_name, attribute_type, keys=None):
    types_mapper = {"string": basestring, "dictionary": dict}
    assert context.response_object[attribute_name]
    assert isinstance(context.response_object[attribute_name], list)

    type_check = types_mapper[attribute_type]
    # check type of each item in array/list
    for item in context.response_object[attribute_name]:
        assert isinstance(item, type_check)
        if keys:
            for key in keys.split():
                assert item.get(key) is not None


@then('an object with array "{attribute_name}" of size "{array_size}"')
@then('an object with array "{attribute_name}" of size "{array_size}" with keys "{keys}"')
@then('response should have array "{attribute_name}"')
@then('response should have array "{attribute_name}" of size "{array_size}"')
@then('response should have array "{attribute_name}" of size "{array_size}" with keys "{keys}"')
def obj_has_array_of_size(context, attribute_name, array_size=None, keys=None):
    assert attribute_name in context.response_object
    assert isinstance(context.response_object[attribute_name], list)
    if array_size is not None:
        num = len(context.response_object[attribute_name])
        assert (num == int(array_size)), '{} != {}'.format(num, array_size)

    if keys:
        for item in context.response_object[attribute_name]:
            for key in keys.split():
                assert item.get(key)


@then('response "{pointer}" should be of type "{type_name}"')
def assert_json_pointer_type(context, pointer, type_name):
    """
    assertion on data type.
    :param context: behave context
    :param pointer: json pointer https://tools.ietf.org/html/rfc6901
    :param type_name: name of the type
    :raises: AssertionError
    """
    result = resolve_pointer(context.response_object, pointer)
    msg = 'expected {} got {}'.format(type_name, result)
    assert isinstance(result, eval(type_name)), msg


@then('response "{pointer}" should be "{value}"')
@then('response "{pointer}" should be integer "{value:d}"')
def assert_json_pointer_value(context, pointer, value):
    """
    assertion on data value.
    :param context: behave context
    :param pointer: json pointer https://tools.ietf.org/html/rfc6901
    :param value: value of the data in string format
    :raises: AssertionError
    """
    result = resolve_pointer(context.response_object, pointer)
    assert value == result, 'expected {} got {}'.format(value, result)


@then('print response')
def print_response(context):
    print context.response.status_code
    print context.response.content
    print context.response.headers
    print context.response_object
    print "-"


@then('the errors should contain an object with "{key}" of "{value}"')
def error_checking(context, key, value):
    errors = context.response_object['errors']
    assert any(error.get(key) == value for error in errors)


@then('response "{attribute_name}" is a non empty array')
def obj_has_non_empty_array(context, attribute_name):
    assert isinstance(context.response_object[attribute_name], list)
    assert len(context.response_object[attribute_name]) != 0


@then('response "{attribute_name}" is an empty array')
def obj_has_non_empty_array(context, attribute_name):
    assert isinstance(context.response_object[attribute_name], list)
    assert len(context.response_object[attribute_name]) == 0


@step('the request body is a list of the following items in "{format}" format')
def req_is_list_in_format(context, format):
    if format == 'JSON':

        def _convert_value(value):
            # items in list are separated by '~'
            if '~' in value:
                return filter(lambda x: x, value.split('~'))
            else:
                return value

        context.body = [
            {key: _convert_value(value)
             for key, value in row.as_dict().iteritems()}
            for row in context.table]


@step('parameter "{parameter}" is a unique string')
def unique_name(context, parameter):
    string = uuid.uuid4()
    context.execute_steps('Given parameter "{}" is "{}"'.format(parameter,
                                                                string))


@step('an object with array "{attribute_name}" of size "{array_size}" with keys "{keys}"')
def obj_with_array_of_size_with_keys(context, attribute_name, array_size, keys):
    context.body = {attribute_name: []}
    for i in range(int(array_size)):
        obj = dict()
        for key in keys.split():
            obj[key] = str(uuid.uuid4())
        context.body[attribute_name].append(obj)


@step('request body has a key of "{key}" with a value of "{value}"')
def set_request_body(context, key, value):
    "Add a key to the request body"
    if not hasattr(context, "body"):
        context.body = {}
    if not context.body:
        context.body = {}
    context.body[key] = value


@then('response "{first_object}" should contain an "{second_object}" object with the {obj} {attr} "{third_object}" of value "{value}"')
def check_inner_object_has_value(context, first_object, second_object, obj, attr, third_object, value):
    "Check that an object within an object has a key"
    item = context.response_object
    assert first_object in item
    assert second_object in item[first_object]

    attribute = getattr(context, obj)[attr]
    assert attribute in item[first_object][second_object]
    assert third_object in item[first_object][second_object][attribute]
    assert item[first_object][second_object][attribute][third_object] == value


@then('a "{first_object}" object with "{second_object}" object with the {obj} {attr}')
@then('response "{first_object}" should contain a "{second_object}" object with the {obj} {attr}')
@then('response "{first_object}" should contain an "{second_object}" object with the {obj} {attr}')
def check_inner_object_has_key(context, first_object, second_object, obj, attr):
    "Check that an object within an object has a key"
    item = context.response_object
    assert first_object in item
    assert second_object in item[first_object]
    assert getattr(context, obj)[attr] in item[first_object][second_object]


@then('a "{first_object}" object with "{second_object}" object without the {obj} {attr}')
@then('response "{first_object}" should contain a "{second_object}" object without the {obj} {attr}')
@then('response "{first_object}" should contain an "{second_object}" object without the {obj} {attr}')
def check_inner_object_does_not_have_key(context, first_object, second_object, obj, attr):
    "Check that an object within an object does not have a key"
    item = context.response_object
    assert first_object in item
    assert second_object in item[first_object]
    assert not getattr(context, obj)[attr] in item[first_object][second_object]


@then(
        'response "{first_object}" should contain a "{second_object}" object with "{attribute_name}" of type "{attribute_type}"')
@then(
        'response "{first_object}" should contain an "{second_object}" object with "{attribute_name}" of type "{attribute_type}"')
def check_inner_object_has_a_key_of_a_certain_type(context, first_object, second_object, attribute_name,
                                                   attribute_type):
    types_mapper = {'string': basestring, 'dictionary': dict}
    item = context.response_object
    assert first_object in item
    assert second_object in item[first_object]
    attribute_type = types_mapper.get(attribute_type) or eval(attribute_type)
    assert isinstance(item[first_object][second_object][attribute_name], attribute_type)


@then('response "{first_object}" should contain a "{second_object}" object without "{attribute_name}"')
def check_inner_object_has_a_key_of_a_certain_type(context, first_object, second_object, attribute_name):
    item = context.response_object
    assert first_object in item
    assert second_object in item[first_object]
    assert not hasattr(item[first_object][second_object], attribute_name)

