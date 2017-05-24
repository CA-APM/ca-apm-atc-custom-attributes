#!/usr/bin/env python
# -*- coding: utf-8 -*-
# pylint: disable=too-many-locals
# June 2016
"""Create/Update APM ATC attributes from a CSV."""
import requests
import json
import csv
import sys

from config import Config


class APMAPI(object):
    """API Client for accessing CA Application Performance Management.

    Args:
        rest_url (str): The api url for APM.
        atc_token (str): The authentication token to access the API.
    """

    def __init__(self, rest_url, auth_token, key_attribute):
        self.rest_url = rest_url
        self.auth_token = auth_token
        self.headers = {
            'Content-type': 'application/hal+json;charset=utf-8',
            'Authorization': 'Bearer {}'.format(self.auth_token)
        }
        self.key_attribute = key_attribute

    def get_vertex_map(self):
        """Get the vertices defined in APM ATC as a dict from key to
        list of integer IDs.

        Returns:
            (Dict[str, List[int]]): The vertex mapping.
        """
        #request_data = json.dumps({'shortName': 'sam'})
        #response = requests.get(self.rest_url, data=request_data,
        response = requests.get(self.rest_url,
                                headers=self.headers, verify=False)
        #print(json.dumps(response.json(), sort_keys=True, indent=4))
        vertices = response.json()['_embedded']['vertex']
        vertex_map = {}
        for vertex in vertices:
            # If the vertex has a key
            if vertex.get('attributes', {}).get(self.key_attribute):
                #print(vertex['attributes'][self.key_attribute])
                #print(json.dumps(vertex, sort_keys=True, indent=4))
                # Append its ID to the list of IDs for that key
                element = vertex_map.\
                        setdefault(vertex['attributes'][self.key_attribute][0], []).\
                        append(vertex['id'])
        return vertex_map

    def update_vertex(self, vertex_id, attributes):
        """Update a vertex in APM ATC with the supplied attributes.

        Args:
            vertex_id (int): The ID of the vertex to update.
            attributes (dict[str, Any]): The attributes to update on the
                vertex.

        Returns:
            (request.models.Response): The HTTP request's response.
        """
        url = self.rest_url + '/' + vertex_id
        payload = {}
        for key in attributes:
            payload[key] = [attributes[key]]

        update_payload = {
            'attributes': payload
        }
        print(update_payload)
        response = requests.patch(url, json=update_payload,
                                  headers=self.headers, verify=False)
        return response


def main():
    """Main program logic."""
    config_section = 'APM Server Configurations'
    config = Config('config.ini', encrypted_keys=('auth_token',))

    rest_url = config.items(config_section)['rest_url']
    auth_token = config.items(config_section)['auth_token']
    file_path = config.items(config_section)['file_path']
    output_file_path = config.items(config_section)['output_file_path']
    key_column = config.items(config_section)['key_column']
    key_attribute = config.items(config_section)['key_attribute']

    """Get whole map as once - maybe better to query by key"""
    apm_api = APMAPI(rest_url, auth_token, key_attribute)
    vertex_map = apm_api.get_vertex_map()

    with open(file_path, 'r') as csm_file, \
        open(output_file_path, 'w') as output_file:
        output_csv = csv.writer(output_file, delimiter=' ', quotechar='|',
                        quoting=csv.QUOTE_MINIMAL)
        output_csv.writerow(['Row', key_column, 'Vertex ID',
                            'API Call Status Code', 'API Call Response Text'])
        for index, row in enumerate(csv.DictReader(csm_file)):
            key = row[key_column]
            # The key attribute should not be part of the update attrs
            del row[key_column]
            if vertex_map.get(key):
                for vertex_id in vertex_map[key]:
                    """Update a single vertex"""
                    response = apm_api.update_vertex(vertex_id, row)
                    output_csv.writerow([index, key, vertex_id,
                                         response.status_code, response.text])
            else:
                output_csv.writerow([index, key, 'No vertices'])


if __name__ == '__main__':
    main()
