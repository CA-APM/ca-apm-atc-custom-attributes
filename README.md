# Auto Create/Update ATC Custom Attributes

# Description
This python script creates n/or updates custom attributes in CA APM Team Center (ATC) from a CSV file.

To better organize the vertices and integrate with other tools, it is easier to leverage the APM ATC custom attributes.

This script reads the vertices from ATC, matches a key attribute (e.g. Hostname) to a column in a CSV file and updates/creates the vertex attributes with the other columns in the CSV file. The first row of the file will be used as headers which will be the attribute keys in ATC.

## Short Description

This python script creates and/or updates custom attributes in CA APM Team Center from a CSV file.

## APM version
Tested with APM 10.5.1. Will not work with APM 10.3 and lower.

## Supported third party versions
Python 3.4.3

## Limitations
n/a

## License
[Eclipse Public License - v 1.0](LICENSE). See [Licensing](https://communities.ca.com/docs/DOC-231150910#license) on the CA APM Developer Community.

Please review the [LICENSE](LICENSE) file in this repository.  Licenses may vary by repository.  Your download and use of this software constitutes your agreement to this license.

# Installation Instructions

## Prerequisites

1. Enable the CA APM Team Center REST API by setting `introscope.public.restapi.enabled=true` in `IntroscopeEnterpriseManager.properties` on your MOM or Enterprise Team Center server and restart the Enterprise Manager.
2. Generate a security token in the CA APM Team Center UI (under Settings/Security). See the [APM REST API Documentation
](https://docops.ca.com/ca-apm/10-5/en/integrating/api-reference-guide/apm-rest-api) for more information.
3. Export data from external data sources (for example CMDB data, Change Orders, etc).

## Dependencies
APM-ATC REST API must be enabled.

## Installation
Copy and extract the atc-custom-attributes.zip.

## Configuration
Update the `config.ini` file with your CA APM MOM or Enterprise Team Center server details and the path to the CSV file. E.g.:

```
[APM Server Configurations]
rest_url = http://<your_em_host>:8081/apm/appmap/graph/vertex
auth_token = abcdef123-4567-8a90-1a2b-3c4d5e6f7890
file_path = test.csv
output_file_path = test.log
key_column = Hostname
key_attribute = hostname
```

1. The first (header) row of the CSV file will be used as attribute names/keys to create/update the ATC attributes. So create the CSV accordingly.
2. By default, the `Hostname` column is the key for reference. You can configure another `key_column` and `key_attribute` in `config.ini`, e.g. `agent` or `Application`. The order of the columns in the file does not matter.
3. Create your custom perspectives, filters or universes in CA APM Team Center with the new attributes. APM 10.2 onwards you can 'Filter' using the custom attributes.

### Sample CSV file format

```
Hostname,Application Group, Business Owner, Technical Owner
server1,app_frontoffice, Scott, Bob
server2,app_frontoffice, Scott, Bob
```

# Usage Instructions
Run `python3 atc.py` from the command line.

## Debugging and Troubleshooting
Refer the log file name mentioned in the `config.ini` file to review the rows which are updated.

## Support
This document and associated tools are made available from CA Technologies as examples and provided at no charge as a courtesy to the CA APM Community at large. This resource may require modification for use in your environment. However, please note that this resource is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. These utilities are not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. They can be used and distributed freely amongst the CA APM Community, but not sold. As such, they are unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this resource implies that you understand and agree to the terms listed herein.

Although these utilities are unsupported, please let us know if you have any problems or questions by adding a comment to the CA APM Community Site area where the resource is located, so that the Author(s) may attempt to address the issue or question.

Unless explicitly stated otherwise this field pack is only supported on the same platforms as the APM core agent. See [APM Compatibility Guide](http://www.ca.com/us/support/ca-support-online/product-content/status/compatibility-matrix/application-performance-management-compatibility-guide.aspx).

### Support URL
https://github.com/CA-APM/ca-apm-atc-custom-attributes/issues

# Contributing
The [CA APM Community](https://communities.ca.com/community/ca-apm) is the primary means of interfacing with other users and with the CA APM product team.  The [developer subcommunity](https://communities.ca.com/community/ca-apm/ca-developer-apm) is where you can learn more about building APM-based assets, find code examples, and ask questions of other developers and the CA APM product team.

If you wish to contribute to this or any other project, please refer to [easy instructions](https://communities.ca.com/docs/DOC-231150910) available on the CA APM Developer Community.

## Categories

Integration


# Change log
Changes for each version of the field pack.

Version | Author | Comment
--------|--------|--------
1.0 | CA Technologies | First version of the script.
1.1 | CA Technologies | use graph API (Enterprise Team Center), python3, remove dependencies
