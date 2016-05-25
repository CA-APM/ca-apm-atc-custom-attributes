#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Update APM ATC with attributes extracted from CMDB."""
import requests
import json
import csv
from core.config import Config


config = Config('config.ini')

url = config.items('APM Server Configurations')['rest_url']
auth_token = config.items('APM Server Configurations')['atc_token']
file_path = config.items('APM Server Configurations')['file_path']

data = {'shortName': "sam"}
data_json = json.dumps(data)
headers = {'Content-type': 'application/hal+json;charset=utf-8','Authorization': 'Bearer ' + auth_token}
response = requests.get(url, data=data_json, headers=headers, verify=False)
all_elements = response.json()["_embedded"]["vertex"]

vertex_name_map = {}
for el in all_elements:
    if el.get('attributes', {}).get('hostname'):
        vertex_name_map.setdefault(el['attributes']['hostname'], []).append(el['id'])

csm_file = open(file_path, 'rb')
csm_reader = csv.DictReader(csm_file)
for row in csm_reader:
    hostname = row['Hostname']
    del row['Hostname']
    if vertex_name_map.get(hostname):
        for vertex_id in vertex_name_map[hostname]:
            update_payload = [{
                "id": vertex_id,
                "attributes": row
            }]
 
            response = requests.patch(url, verify=False, headers=headers, json=update_payload)
csm_file.close()

