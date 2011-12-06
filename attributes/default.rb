default[:statsd][:repo] = "git://github.com/librato/statsd.git"

default[:statsd][:log_file] = "/var/log/statsd.log"

default[:statsd][:port] = 8125
default[:statsd][:graph_service] = 'graphite' # also librato-metrics

default[:statsd][:graphite_port] = 2003
default[:statsd][:graphite_host] = "localhost"

# Set these for librato-metrics graph service
default[:statsd][:librato_email] = ''
default[:statsd][:librato_api_token] = ''
