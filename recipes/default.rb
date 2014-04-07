#
# Cookbook Name:: statsd
# Recipe:: default
#
# Copyright 2011, Librato, Inc.
#

include_recipe "nodejs"
include_recipe "git"

git "/usr/share/statsd" do
  repository node[:statsd][:repo]
  revision node[:statsd][:version]
  action :sync
end

execute "install dependencies" do
  command "npm install -d"
  cwd "/usr/share/statsd"
end

backends = []

if node[:statsd][:graphite_enabled]
  backends << "./backends/graphite"
end

node[:statsd][:backends].each do |k, v|
  if v
    name = "#{k}@#{v}"
  else
    name= k
  end

  execute "install npm module #{name}" do
    command "npm install #{name}"
    cwd "/usr/share/statsd"
  end

  backends << k
end

directory "/etc/statsd" do
  action :create
end

user "statsd" do
  comment "statsd"
  system true
  shell "/bin/false"
end

template "/etc/statsd/config.js" do
  source "config.js.erb"
  owner "statsd"

  config_hash = {
    :flushInterval => node[:statsd][:flush_interval_msecs],
    :port => node[:statsd][:port],
    :deleteIdleStats => node[:statsd][:delete_idle_stats],
    :backends => backends
  }.merge(node[:statsd][:extra_config])

  if node[:statsd][:graphite_enabled]
    config_hash[:graphitePort] = node[:statsd][:graphite_port]
    config_hash[:graphiteHost] = node[:statsd][:graphite_host]
  end

  variables(:config_hash => config_hash)

  notifies :restart, "service[statsd]", :delayed
end

template "/etc/init/statsd.conf" do
  source "upstart.conf.erb"
  notifies :restart, "service[statsd]", :delayed
end

file "create_log_file" do
  path node[:statsd][:log_file]
  owner "statsd"
end

service "statsd" do
  provider Chef::Provider::Service::Upstart
  supports :restart => false
  action [ :enable, :start ]
end
