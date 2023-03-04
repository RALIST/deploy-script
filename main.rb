# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require_relative 'config'

instance = Config.instance
config = instance.config

config['servers'].compact.each do |server|
  next if server['host'].nil? || server['host'] == ''
  options = instance.config_for(server)
  commands = config['commands'] || []
  commands += server['commands'] || []
  raw_commands = commands.join(' && ')

  Net::SSH.start(options.delete(:host), options.delete(:user), **options) do |ssh|
    channel = ssh.open_channel do |ch|
      ch.exec raw_commands
    end

    channel.on_data do |_ch, data|
      puts data
    end

    channel.on_extended_data do |_ch, _type, data|
      puts data
    end

    channel.on_close do
      puts 'Closing channel'
    end

    channel.wait
  end
end
