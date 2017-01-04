control 'upstart' do
  title 'Ensure statsd runs correctly under upstart'

  service_file = '/etc/init/statsd.conf'

  only_if do
    file(service_file).exist?
  end

  describe file(service_file) do
    it { should exist }
  end
end
