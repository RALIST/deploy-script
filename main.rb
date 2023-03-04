# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require 'yaml'

config = YAML.load(File.read('config.yml'))

def config_for(server = {}, config = {})
  options = {}
  options[:user] = server['user']  unless server['user'].nil? || server['user'] == ''
  options[:user] ||= server['user']
  options[:host] = server['host'] unless server['host'].nil? || server['host'] == ''
  options[:password] = server['password'] unless server['password'].nil? || server['password'] == ''
  options[:password] ||= config['password']

  unless config['certs'].nil? && config['certs'].is_a?(Array)
    config['certs'].reject!{|v| v == nil || v == ''}
    options[:keycerts] = config['certs']
  end

  options.merge!(port: server['port']) unless server['port'].nil? || server['port'] == ''

  options
end

config['servers'].compact.each do |server|
  next if server['host'].nil? || server['host'] == ''
  options = config_for(server, config)

  conn = Net::SSH.start(options.delete(:host), options.delete(:user), **options)
  commands = config['commands'] + server['commands']
  commands.compact.each do |command|
    res = conn.exec!(command)
    puts res
  end

  conn.close
end
