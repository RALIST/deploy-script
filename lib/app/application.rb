class Application
  def self.start
    new.start
  end

  attr_reader :config, :config_instance

  def initialize
    @config_instance = Config.instance
    @config = @config_instance.config
  end

  def start
    config['servers'].compact.each do |server|
      next if server['host'].nil? || server['host'] == ''

      options = config_instance.config_for(server)
      ExecutionWorker.perform_async(options)
    end
  end
end