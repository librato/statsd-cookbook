control 'default' do
  title 'Ensure statsd is running and available'
  
  describe service('statsd') do
    it { should be_enabled }
    it { should be_running }
  end
  
  describe port('8125') do
    it { should be_listening }
    its('protocols') { should include 'udp' }
    its('processes') { should include 'statsd' }
  end
end
