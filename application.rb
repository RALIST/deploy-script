require 'rubygems'
require 'bundler/setup'
require 'pathname'

Bundler.require(:default)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '/lib')
$root = Pathname.new('').expand_path(File.dirname(__FILE__))

Dir.glob(File.join(File.dirname(__FILE__), 'lib/**/*.rb')).each do |fname|
  load fname
end

Application.start
