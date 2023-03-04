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
  server_data = []

  Net::SSH.start(options.delete(:host), options.delete(:user), **options) do |ssh|
    channel = ssh.open_channel do |ch|
      puts "Executing commands in server #{server['host']}..."
      ch.exec raw_commands
    end

    channel.on_data do |_ch, data|
      server_data << data
    end

    channel.on_extended_data do |_ch, _type, data|
      server_data << data
    end

    channel.on_close do
      puts 'Closing channel'
    end

    channel.wait
  rescue => e
    server_data << ["There was error while executing commands: #{e.message}"]
    next
  ensure
    File.open("log/#{server['host']}.log", "w") { |file| file.write(server_data.join)}
  end
end
