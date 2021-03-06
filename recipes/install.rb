#
# Cookbook Name:: statsd
# Recipe:: install
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

include_recipe 'nodejs'
include_recipe 'git'

git node['statsd']['path'] do
  repository node['statsd']['repo']
  revision node['statsd']['version']
  action :sync
  notifies :run, 'execute[install StatsD dependencies]', :immediately
end

execute 'install StatsD dependencies' do
  command 'npm install -d'
  cwd node['statsd']['path']
  action :nothing
end
