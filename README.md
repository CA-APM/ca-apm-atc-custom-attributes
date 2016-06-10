# Auto Create/Update ATC Custom Attributes
*__NOTE TO CONTRIBUTORS:__ Items marked in italics provide how-to guidance in creating this file.  These comments should be removed once proper content has been added.  Other non-italicized text should remain in this file as boilerplate text.*


*__NOTE TO CONTRIBUTORS:__ Projects are designed to be self documenting in this README file.  Rich text (including screenshots) can be  found inside the projects themselves (as committed assets).  Generally a project overview (including description, sample screenshots, etc.) can be found on the project wiki page at `http://github.com/ca-apm/<repo_name>/wiki`.* 

# Description
*Provide a short description of the field pack here. See [Markdown Basics](https://help.github.com/articles/markdown-basics/) for markdown syntax.*
This field pack helps create/update custom attributes in ATC

##Short Description

*A description of less that 140 characters long, required for APM Marketplace*
To better organise the vertices and integrate with other tools, it is easier to leverage the APM ATC custom attributes.
This script GETs the Hostname from APM/ATC and looks for Hostname from a CSV file and using ATC RestAPI updates/create the the vertices  attributes with the columns in the csv.
The first row will be considered as Headers which will be the Custom Attributes in APM/ATC


## APM version
*APM EM and agent versions the field pack has been tested with.*
APM 10.1
## Supported third party versions
*Third party versions tested with.*

## Limitations
*What the field pack will not do.*

## License
*Link to the license under which this field pack is provided. See [Licensing](https://communities.ca.com/docs/DOC-231150910#license) on the CA APM Developer Community.*

Please review the 
**LICENSE**
file in this repository.  Licenses may vary by repository.  Your download and use of this software constitutes your agreement to this license.

# Installation Instructions
1. Copy and extract the atc.zip locally.
2. Update the config.ini file with your APM ATC details and path to the CSV file




You might see some warnings about 'unsecure' communications if you are not using https. you can ignore them.


## Prerequisites
*What has to be done before installing the field pack.*
1. Enable the RestAPI
2. Generate Token from ATC

Export data from external data sourcecs (for example CMDB data, Change Orders, etc)
## Dependencies 
*APM and third party dependencies. E.g. APM agent 9.1+, SOA (web services) extension 9.1+*

APM REST API

## Installation
*How to install the field pack.*

## Configuration
*How to configure the field pack.*
1. The CSV file first row will be the headers and will be used to create/update the APM/ATC attributes. So create the CSV accordingly.
2. The Hostname column is the key for reference. Please mention in the config.ini which column header the script should look for the hostnames. The column order does not matter.
3. Create your Custom Perspectives in APM/ATC with the new attributes. APM 10.2 onwards you can 'Filter' using the custom attributes

Sample CSV file format
Hostname,Application Group, Business Owner, Technical Owner
server1,app_frontoffice, Scott, Bob
server2,app_frontoffice, Scott, Bob

# Usage Instructions
*How to use the field pack.*
Navigate to the atc.exe in DOS command prompt and run the exe.

## Metric description
*Describe the metrics provided by this field pack or link to third party documentation.*

## Custom Management Modules
*Dashboards, etc. included with this field pack.*

## Custom type viewers
*Type viewers included with this field pack. Include agent and metric path that the type viewer matches against.*

## Name Formatter Replacements
*If the field pack includes name formatters cite all place holders here and what they are replaced with.*

## Debugging and Troubleshooting
*How to debug and troubleshoot the field pack.*
Refer the log file name mentioned in the config.ini file to review the rows which are updated.

## Support
This document and associated tools are made available from CA Technologies as examples and provided at no charge as a courtesy to the CA APM Community at large. This resource may require modification for use in your environment. However, please note that this resource is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. These utilities are not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. They can be used and distributed freely amongst the CA APM Community, but not sold. As such, they are unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this resource implies that you understand and agree to the terms listed herein.

Although these utilities are unsupported, please let us know if you have any problems or questions by adding a comment to the CA APM Community Site area where the resource is located, so that the Author(s) may attempt to address the issue or question.

Unless explicitly stated otherwise this field pack is only supported on the same platforms as the APM core agent. See [APM Compatibility Guide](http://www.ca.com/us/support/ca-support-online/product-content/status/compatibility-matrix/application-performance-management-compatibility-guide.aspx).

### Support URL
https://github-isl-01.ca.com/GIS/APM-ATC-Custom-Attributes/issues

# Contributing
The [CA APM Community](https://communities.ca.com/community/ca-apm) is the primary means of interfacing with other users and with the CA APM product team.  The [developer subcommunity](https://communities.ca.com/community/ca-apm/ca-developer-apm) is where you can learn more about building APM-based assets, find code examples, and ask questions of other developers and the CA APM product team.

If you wish to contribute to this or any other project, please refer to [easy instructions](https://communities.ca.com/docs/DOC-231150910) available on the CA APM Developer Community.

## Categories

Integration


# Change log
Changes for each version of the field pack.

Version | Author | Comment
--------|--------|--------
1.0 | ${env.USERNAME} | First version of the field pack.
