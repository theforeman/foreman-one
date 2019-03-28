# Foreman OpenNebula Plugin

**This plugin has been discontinued. The latest release only helps with its removal. If you're interested in taking over the maintanance, let us know. See https://community.theforeman.org/t/foreman-opennebula-plugin-sunsetting/13436 for more details**

In order to remove the plugin from your Foreman installation, following steps need to be taken

1. make a backup
1. remove all Open Nebula compute resources you defined
1. uninstall the plugin by running `yum remove tfm-rubygem-foreman_one` or `apt remove ruby-foreman-one`

## Description

This plugin enables provisioning and managing OpenNebula VMs in Foreman.

## Installation

Please see the Foreman manual for appropriate instructions:

* [Foreman: How to Install a Plugin](http://theforeman.org/manuals/latest/index.html#6.1InstallaPlugin)

The gem name is "foreman_one".

## Compatibility

| Foreman Version | Plugin Version |
| ---------------:| --------------:|
| >=  1.5         | 0.1            |
| >=  1.8         | 0.3            |

## Latest code (recommended)

To use foreman-one with newer Versions of TheForeman >=1.8 you should add the
following lines to your Gemfile. 

    gem 'foreman_one', :git => "https://github.com/theforeman/foreman-one.git"
    gem "fog", :git => "https://github.com/netways/fog.git", :branch => "net-v1.33.0"

# Copyright

Copyright (c) 2014 NETWAYS Managed Services GmbH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
