require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '12.04'
  config.log_level = :error
end

at_exit { ChefSpec::Coverage.report! }
