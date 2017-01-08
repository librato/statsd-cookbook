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

template '/etc/systemd/system/statsd.service' do
  source 'systemd.service.erb'
  action :create
end

service 'statsd' do
  provider Chef::Provider::Service::Systemd
  supports restart: true, start: true, stop: true
  action :nothing
end
