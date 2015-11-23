require 'spec_helper'

describe 'statsd::default' do
  cached(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  cached(:node) { chef_run.node }
  cached(:config) do
    chef_run.template("#{node['statsd']['config_dir']}/config.js")
  end
  cached(:upstart) do
    chef_run.template('/etc/init/statsd.conf')
  end
  cached(:git) do
    chef_run.git(node['statsd']['path'])
  end

  %w(nodejs git).each do |recipe|
    it "includes the #{recipe} recipe" do
      expect(chef_run).to include_recipe(recipe)
    end
  end

  it 'syncs statsd with upstream' do
    expect(chef_run).to sync_git(node['statsd']['path']) \
    .with(
      repository: node['statsd']['repo'],
      revision: node['statsd']['version']
    )
  end

  it 'notifies to install statsd dependencies' do
    expect(git).to notify('execute[install StatsD dependencies]').to(:run).immediately
  end

  it 'only installs statsd dependencies if git notified' do
    expect(chef_run).to_not run_execute('npm install -d') \
    .with(cwd: node['statsd']['path'])
  end

  it 'creates the statsd config directory' do
    expect(chef_run).to create_directory(node['statsd']['config_dir'])
  end

  it 'creates or modify a "statsd" user' do
    expect(chef_run).to create_user(node['statsd']['user']) \
    .with(
      comment: 'statsd',
      system: true,
      shell: '/bin/false'
    )
  end

  it 'enables and starts an upstart service "statsd"' do
    expect(chef_run).to enable_service('statsd') \
    .with(
      provider: Chef::Provider::Service::Upstart,
      restart_command: 'stop statsd; start statsd',
      start_command: 'start statsd',
      stop_command: 'stop statsd'
    )
    expect(chef_run).to start_service('statsd') \
    .with(
      provider: Chef::Provider::Service::Upstart,
      restart_command: 'stop statsd; start statsd',
      start_command: 'start statsd',
      stop_command: 'stop statsd'
    )
  end

  it 'creates a config file for statsd and notifies statsd service' do
    expect(chef_run).to create_template("#{node['statsd']['config_dir']}/config.js") \
    .with(
      source: 'config.js.erb',
      owner: node['statsd']['user'],
      group: node['statsd']['group'],
      mode: 0644
    )
    expect(config).to notify('service[statsd]').to(:restart).delayed
  end

  it 'create an upstart script for statsd and restart the service when modified' do
    expect(chef_run).to create_template('/etc/init/statsd.conf') \
    .with(
      source: 'upstart.conf.erb',
      mode: 0644
    )
    expect(upstart).to notify('service[statsd]').to(:restart).delayed
  end

  it 'creates a log file for statsd' do
    expect(chef_run).to create_file_if_missing(node['statsd']['log_file']) \
    .with(
      owner: node['statsd']['user'],
      group: node['statsd']['group']
    )
  end
  
end
