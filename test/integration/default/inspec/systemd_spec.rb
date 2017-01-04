control 'systemd' do
  title 'Ensure statsd runs correctly under systemd'

  service_file = '/etc/systemd/system/statsd.service'

  only_if do
    file(service_file).exist?
  end

  describe file(service_file) do
    it { should exist }
  end
end
