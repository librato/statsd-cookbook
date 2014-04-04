#
# Cookbook Name:: statsd
# Recipe:: default
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
end

execute 'install dependencies' do
  command 'npm install -d'
  cwd node['statsd']['path']
end

backends = []

if node['statsd']['graphite_enabled']
  backends << "./backends/graphite"
end

node['statsd']['backends'].each do |k, v|
  if v
    name = "#{k}@#{v}"
  else
    name = k
  end

  execute "install npm module #{name}" do
    command "npm install #{name}"
    cwd node['statsd']['path']
  end

  backends << k
end

directory node['statsd']['config_dir']

user node['statsd']['user'] do
  comment 'statsd'
  system true
  shell '/bin/false'
end

service 'statsd' do
  provider Chef::Provider::Service::Upstart
  restart_command 'stop statsd; start statsd'
  start_command 'start statsd'
  stop_command 'stop statsd'
  supports restart: true, start: true, stop: true
end

template "#{node['statsd']['config_dir']}/config.js" do
  source 'config.js.erb'
  owner node['statsd']['user']
  group node['statsd']['group']
  mode 0644

  config_hash = {
    flushInterval: node['statsd']['flush_interval_msecs'],
    port: node['statsd']['port'],
    deleteIdleStats: node['statsd']['delete_idle_stats'],
    backends: backends
  }

  if node['statsd']['graphite_enabled']
    config_hash[:graphite] = { legacyNamespace: node['statsd']['legacyNamespace'] }
    config_hash[:graphitePort] = node['statsd']['graphite_port']
    config_hash[:graphiteHost] = node['statsd']['graphite_host']
  end

  config_hash = config_hash.merge(node['statsd']['extra_config'])
  variables config_hash: config_hash
  notifies :restart, 'service[statsd]', :delayed
end

template '/etc/init/statsd.conf' do
  source 'upstart.conf.erb'
  mode 0644
  notifies :restart, 'service[statsd]', :delayed
end

file "#{node['statsd']['log_file']}" do
  owner node['statsd']['user']
  group node['statsd']['group']
  action :touch
  not_if { File.exist?(node['statsd']['log_file']) }
end

directory "#{node['statsd']['pid_dir']}" do
  owner node['statsd']['user']
  group node['statsd']['group']
  mode 0755
end
