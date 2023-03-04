# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require 'yaml'
require_relative 'config'

instance = Config.instance
config = instance.config

config['servers'].compact.each do |server|
  next if server['host'].nil? || server['host'] == ''
  options = instance.config_for(server)

  conn = Net::SSH.start(options.delete(:host), options.delete(:user), **options)
  commands = config['commands'] || []
  commands += server['commands'] || []
  commands.compact.each do |command|
    res = conn.exec!(command)
    puts res
  end

  conn.close
end
