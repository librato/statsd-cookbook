default['statsd']['repo'] = "git://github.com/etsy/statsd.git"
default['statsd']['version'] = "master"

default['statsd']['log_file'] = "/var/log/statsd.log"

default['statsd']['dump_messages'] = false
default['statsd']['flush_interval_msecs'] = 10000
default['statsd']['port'] = 8125

# valid options: [nil, "ipaddress", "localhost", "private-ipaddress"]
default['statsd']['bind'] = nil

default['statsd']['graphite'] = {}
default['statsd']['graphite']['enabled'] = true
default['statsd']['graphite']['port'] = 2003
default['statsd']['graphite']['search'] = nil
default['statsd']['graphite']['host'] = "localhost"

#
# Add all NPM module backends here. Each backend should be a
# hash of the backend's name to the NPM module's version. If we
# should just use the latest, set the hash to null.
#
# For example, to use version 0.0.1 of statsd-librato-backend:
#
#   attrs[:statsd][:backends] = { 'statsd-librato-backend' => '0.0.1' }
#
# To use the latest version of statsd-librato-backend:
#
#   attrs[:statsd][:backends] = { 'statsd-librato-backend' => nil }
#
default['statsd']['backends'] = {}

#
# Add any additional backend configuration here.
#
default['statsd']['extra_config'] = {}

#
# Set a chef search string to find a repeater (ie. "roles:statsd-repeater")
#
default['statsd']['repeater'] = {
    "search" => nil,
    "port" => 8125,
    # bind valid options: ["ipaddress", "private-ipaddress"]
    "bind" => "ipaddress"
}

default["statsd"]["start_command"] = nil
default["statsd"]["stop_command"] = nil
default["statsd"]["restart_command"] = nil

case platform
  when "ubuntu"
    default["statsd"]["init_style"] = "init"
    default["statsd"]["provider"] = Chef::Provider::Service::Upstart
    default["statsd"]["start_command"] = "start statsd"
    default["statsd"]["stop_command"] = "stop statsd"
    default["statsd"]["restart_command"] = "stop statsd; start statsd"
    default["statsd"]["dir"] = "/usr/share/statsd"
    default["statsd"]["bin_path"] = "/usr/local/bin"
  when "smartos"
    default["statsd"]["init_style"] = "smf"
    default["statsd"]["provider"] = Chef::Provider::Service::Solaris
    default["statsd"]["dir"] = "/opt/statsd"
    default["statsd"]["node_path"] = "/opt/local/bin/node"
    default["statsd"]["bin_path"] = "/opt/local/bin"
  else
    default["statsd"]["init_style"] = "init"
    default["statsd"]["provider"] = Chef::Provider::Service::Upstart
    default["statsd"]["start_command"] = "start statsd"
    default["statsd"]["stop_command"] = "stop statsd"
    default["statsd"]["restart_command"] = "stop statsd; start statsd"
    default["statsd"]["dir"] = "/usr/share/statsd"
    default["statsd"]["bin_path"] = "/usr/local/bin"
end
