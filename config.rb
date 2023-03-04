require 'singleton'
require 'yaml'

class Config
  include Singleton

  attr_reader :config
  def initialize
    @file = File.read('config.yml')
    @config = YAML.load(@file)
  end

  def config_for(server = {})
    options = {}
    %w[host port user password].each do |key|
      options[key.to_sym] = server[key] if present?(server, key)
      options[key.to_sym] ||= config[key] if present?(config, key)
    end

    unless config['certs'].nil? && config['certs'].is_a?(Array)
      config['certs'].reject!{|v| v == nil || v == ''}
      options[:keycerts] = config['certs']
    end

    options
  end

  def present?(hash, key)
    !(hash[key].nil? || hash[key] == '')
  end
end