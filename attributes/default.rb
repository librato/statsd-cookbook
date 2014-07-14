#
# Cookbook Name:: statsd
# Attributes:: default
#
# Copyright 2014, Librato, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['statsd']['repo'] = 'https://github.com/etsy/statsd.git'
default['statsd']['version'] = 'v0.7.1'

default['statsd']['log_file'] = '/var/log/statsd.log'
default['statsd']['config_dir'] = '/etc/statsd'
default['statsd']['pid_dir'] = '/var/run/statsd'
default['statsd']['pid_file'] = '/var/run/statsd/statsd.pid'
default['statsd']['path'] = '/usr/share/statsd'

default['statsd']['user'] = 'statsd'
default['statsd']['group'] = 'statsd'

default['statsd']['flush_interval_msecs'] = 10_000
default['statsd']['port'] = 8125

# Do we automatically delete idle stats?
default['statsd']['delete_idle_stats'] = false

# Is the graphite backend enabled?
default['statsd']['graphite_enabled'] = true
default['statsd']['graphite_port'] = 2003
default['statsd']['graphite_host'] = 'localhost'

#
# Add all NPM module backends here. Each backend should be a
# hash of the backend's name to the NPM module's version. If we
# should just use the latest, set the hash to null.
#
# For example, to use version 0.0.1 of statsd-librato-backend:
#
#   attrs['statsd']['backends] = { 'statsd-librato-backend' => '0.0.1' }
#
# To use the latest version of statsd-librato-backend:
#
#   attrs['statsd']['backends] = { 'statsd-librato-backend' => nil }
#
default['statsd']['backends'] = {}

#
# Starting with v 0.50 default namespace conventions for StatsD have changed.
# The 'new' default is legacyNamespace = True, though this may cause confusion
# for earlier users.  Reference: https://github.com/etsy/statsd/blob/master/docs/namespacing.md
#
default['statsd']['legacyNamespace'] = true

#
# Add any additional backend configuration here.
#
default['statsd']['extra_config'] = {}
