require 'serverspec'

include Serverspec::Helper::Exec
# Force Debian to properly detect statsd service for upstart on CentOS 6.
include Serverspec::Helper::Debian

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe 'statsd service' do
  it 'should be configured for upstart' do
    expect(file('/etc/init/statsd.conf')).to be_file
  end

  it 'should be enabled' do
    expect(service('statsd')).to be_enabled
  end

  it 'should be running' do
    expect(service('statsd')).to be_running
  end

  it 'should be listening' do
    expect(port('8125')).to be_listening.with('udp')
  end
end
