import requests
import json
import ast
import csv
#import pdb
import logging
import sys
import httplib
#httplib.HTTPConnection.debuglevel = 1
#logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
#logging.getLogger().setLevel(logging.DEBUG)
#requests_log = logging.getLogger('requests.packages.urllib3')
#requests_log.setLevel(logging.DEBUG)
#requests_log.propagate = True
#requests_log2 = logging.getLogger('requests.packages.urllib3.connectionpool')
#requests_log2.setLevel(logging.DEBUG)
#requests_log2.propagate = True
#pdb.set_trace()

url = 'https://10.144.7.38:8444/apm/appmap/vertex'

data = {'shortName': "sam"}
data_json = json.dumps(data)
headers = {'Content-type': 'application/hal+json;charset=utf-8','Authorization': 'Bearer e7130a9d-2886-4af2-ac4d-5c1655059b29'}
response = requests.get(url, data=data_json, headers=headers, verify=False)
allElements = response.json()["_embedded"]["vertex"]

vertex_name_map = {}
for el in allElements:
    if el.get('attributes', {}).get('hostname'):
        vertex_name_map.setdefault(el['attributes']['hostname'], []).append(el['id'])
csmFile=open(r"c:\Dumps\appdata.csv", 'rb')
csmReader = csv.DictReader(csmFile)
for row in csmReader:
    hostname = row['Hostname']
    del row['Hostname']
    if vertex_name_map.get(hostname):
        for vertex_id in vertex_name_map[hostname]:
            update_payload = [{
                "id": vertex_id,
                "attributes": row
            }]
            #print update_payload
            #print json.dumps(update_payload)
            response = requests.patch(url, verify=False, headers=headers, json=update_payload)
            #print response
            #print response.text
csmFile.close()

