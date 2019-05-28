#
# Cookbook Name:: statsd
# Recipe:: service
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

service_status = node['statsd']['service'].map do |a, s|
  case a.to_s
  when 'enable'
    s == false ? :disable : :enable
  when 'start'
    s == false ? :stop : :start
  end
end

# Install our init script.
template '/etc/init/statsd.conf' do
  source 'upstart.conf.erb'
  mode 0644
  notifies :restart, 'service[statsd]', :delayed unless service_status.any? { |x| [:disable, :stop].include?(x) }
end

# Set up our service.
service 'statsd' do
  provider Chef::Provider::Service::Upstart
  restart_command 'stop statsd; start statsd'
  start_command 'start statsd'
  stop_command 'stop statsd'
  supports restart: true, start: true, stop: true
  action :nothing
end
