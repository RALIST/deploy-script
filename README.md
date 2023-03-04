### Small script for dealing with multiple servers
it can be performed in sync/async mode (check config.yml)
### Install
- install ruby
- gem install bundler
- bundle install
- cp lib/config/config.example.yml lib/config/config.yml
- chmod +x bin/sidekiq.sh
- chmod +x bin/start
- fill config
- bin/sidekiq.sh
- bundle exec bin/start