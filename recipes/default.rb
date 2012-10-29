#
# Cookbook Name:: statsd
# Recipe:: default
#
# Copyright 2011, Librato, Inc.
#

include_recipe "nodejs"
include_recipe "git"
include_recipe "ohai-private-ipaddress"

git node['statsd']['dir'] do
  repository node['statsd']['repo']
  revision node['statsd']['version']
  action :sync
end

execute "install dependencies" do
  command "npm install -d"
  cwd "/usr/share/statsd"
end

backends = []

if node['statsd']['graphite_enabled']
  backends << "./backends/graphite"
end

node['statsd']['backends'].each do |k, v|
  if v
    name = "#{k}@#{v}"
  else
    name= k
  end

  execute "install npm module #{name}" do
    command "npm install #{name}"
    cwd node['statsd']['dir']
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

# register service
service "statsd" do
  provider node['statsd']['provider']

  restart_command node['statsd']['restart_command'] if node['statsd']['restart_command']
  start_command node['statsd']['start_command'] if node['statsd']['start_command']
  stop_command node['statsd']['stop_command'] if node['statsd']['stop_command']

  supports :restart => true, :start => true, :stop => true
end

# find and enable repeaters
repeaters = []
if node['statsd']['repeater']['search']

  repeater_hosts = search('node', node['statsd']['repeater']['search'])
  unless repeater_hosts.empty?
    repeater_hosts.each do |host|
      repeaters << {
          "host" => host[node['statsd']['repeater']['bind']],
          "port" => node['statsd']['repeater']['port']
      }
    end
  end

  backends << './backends/repeater' unless repeaters.empty?
end

# write statsd config file
template "/etc/statsd/config.js" do
  source "config.js.erb"
  mode 0644

  config_hash = {
    'flushInterval' => node['statsd']['flush_interval_msecs'],
    'dumpMessages' => node['statsd']['dump_messages'],
    'port' => node['statsd']['port'],
    'backends' => backends
  }.merge(node['statsd']['extra_config'])

  case node['statsd']['bind']
    when "ipaddress"
      config_hash["address"] = node["ipaddress"]
      config_hash["mgmt_address"] = node["ipaddress"]
    when "localhost"
      config_hash["address"] = "127.0.0.1"
      config_hash["mgmt_address"] = "127.0.0.1"
    when "private-ipaddress"
      config_hash["address"] = node["private_ipaddress"]
      config_hash["mgmt_address"] = node["private_ipaddress"]
  end

  if node['statsd']['graphite_enabled']
    config_hash['graphitePort'] = node['statsd']['graphite_port']
    config_hash['graphiteHost'] = node['statsd']['graphite_host']
  end

  unless repeaters.empty?
    config_hash["repeaters"] = repeaters
  end

  variables(:config_hash => config_hash)

  notifies :restart, resources(:service => "statsd")
end


case node['statsd']['init_style']
  when 'init'
    directory "#{node['statsd']['dir']}/scripts" do
      action :create
    end

    template "#{node['statsd']['dir']}/scripts/start" do
      source "upstart.start.erb"
      mode 0755

      notifies :restart, resources(:service => "statsd")
    end

    cookbook_file "/etc/init/statsd.conf" do
      source "upstart.conf"
      mode 0644

      notifies :restart, resources(:service => "statsd")
    end
  when 'smf'
    include_recipe "smf"
    smf "statsd" do
      statsd_js = "#{node['statsd']['dir']}/stats.js"

      credentials_user  'statsd'
      start_command     "node #{statsd_js} /etc/statsd/config.js &"
      start_timeout     15
      working_directory node['statsd']['dir']
      environment(
          "PATH" => node['statsd']['bin_path']
      )
    end
end

bash "create_log_file" do
  code <<EOH
touch #{node['statsd']['log_file']} && chown statsd #{node['statsd']['log_file']}
EOH
  not_if {File.exist?(node['statsd']['log_file'])}
end

service "statsd" do
  action [ :enable, :start ]
end
