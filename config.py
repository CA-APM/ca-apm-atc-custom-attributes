#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Class for working with encrypted config files."""
from __future__ import print_function
import base64
import sys

if (sys.version_info > (3, 0)):
    # Python 3 code in this block
    import configparser
else:
    # Python 2 code in this block
    import ConfigParser as configparser


ENCRYPTED_KEYS = (
    'password',
    'secret'
)


class Config(object):
    """Class for working with encrypted INI files.

    Args:
        file_name (str): name of encrypted config file.
    """

    def __init__(self, file_name, encrypted_keys=ENCRYPTED_KEYS):
        """Create a new instance of this class."""
        self._config = configparser.ConfigParser()
        new_config = configparser.ConfigParser()
        self._config.read(file_name)
        entropy = ''
        config_modified = False
        # Read each INI section
        for section in self._config.sections():
            if not new_config.has_section(section):
                new_config.add_section(section)
            # Read each value in the section
            for key, value in self._config.items(section):
                new_config.set(section, key, value)
        # Only rewrite the config if there were secrets that needed
        # encrypting
        if config_modified:
            with open(file_name, 'w') as f:
                new_config.write(f)

    def items(self, section_name):
        """Get the values for the given section.

        Args:
            section_name (str): the name of the section to retrieve.

        Returns:
            dict: a dictionary of the values for the config section.
        """
        return dict(self._config.items(section_name))
