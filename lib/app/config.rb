require 'singleton'
require 'yaml'

CONFIG_PATH = $root.join('lib','config', 'config.yml')

class Config
  include Singleton

  attr_reader :config
  def initialize
    @file = File.read(CONFIG_PATH)
    @config = YAML.load(@file)
  end

  def config_for(server = {})
    options = {}
    %w[host port user password].each do |key|
      options[key] = server[key] if present?(server, key)
      options[key] ||= config[key] if present?(config, key)
    end

    commands = config['commands'] || []
    commands += server['commands'] || []

    options['commands'] = commands

    return options if config['certs'].nil?

    if config['certs'].is_a?(Array)
      config['certs'].reject!{|v| v == nil || v == ''}
      options['keycerts'] = config['certs']
    end

    options
  end

  def present?(hash, key)
    !(hash[key].nil? || hash[key] == '')
  end
end