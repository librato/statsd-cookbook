name             'statsd'
maintainer       'Mike Heffner'
maintainer_email 'mike@librato.com'
license          'Apache 2.0'
description      'Installs/Configures statsd'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.6'

depends 'build-essential'
depends 'git'
depends 'nodejs', '>= 0.5.2'

supports 'ubuntu'
supports 'centos', '~> 6.0'
supports 'amazon'
