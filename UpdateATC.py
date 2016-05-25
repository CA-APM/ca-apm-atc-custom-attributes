#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Update APM ATC with attributes extracted from CMDB."""
import requests
import json
import csv
from core.config import Config


class APMAPI(object):
    """API Client for accessing CA Application Performance Management.

    Args:
        rest_url (str): The api url for APM.
        atc_token (str): The authentication token to access the API.
    """

    def __init__(self, rest_url, auth_token):
        self.rest_url = rest_url
        self.auth_token = auth_token
        self.headers = {
            'Content-type': 'application/hal+json;charset=utf-8',
            'Authorization': 'Bearer {}'.format(self.auth_token)
        }

    def get_vertex_map(self):
        """Get the vertices defined in APM ATC as a dict from hostname to
        list of integer IDs.

        Returns:
            (Dict[str, List[int]]): The vertex mapping.
        """
        request_data = json.dumps({'shortName': 'sam'})
        response = requests.get(self.rest_url, data=request_data,
                                headers=self.headers, verify=False)
        vertices = response.json()['_embedded']['vertex']
        vertex_map = {}
        for vertex in vertices:
            # If the vertex has a hostname
            if vertex.get('attributes', {}).get('hostname'):
                # Append its ID to the list of IDs for that hostname
                vertex_map.\
                        setdefault(vertex['attributes']['hostname'], []).\
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
        update_payload = [{
            'id': vertex_id,
            'attributes': attributes
        }]
        response = requests.patch(self.rest_url, json=update_payload,
                                  headers=self.headers, verify=False)
        return response


def main():
    """Main program logic."""
    config_section = 'APM Server Configurations'
    config = Config('config.ini')

    rest_url = config.items(config_section)['rest_url']
    auth_token = config.items(config_section)['auth_token']
    file_path = config.items(config_section)['file_path']

    apm_api = APMAPI(rest_url, auth_token)
    vertex_map = apm_api.get_vertex_map()

    with open(file_path, 'rb') as csm_file:
        for row in csv.DictReader(csm_file):
            hostname = row['Hostname']
            # The Hostname attribute should not be part of the update attrs
            del row['Hostname']
            if vertex_map.get(hostname):
                for vertex_id in vertex_map[hostname]:
                    apm_api.update_vertex(vertex_id, row)


if __name__ == '__main__':
    main()
