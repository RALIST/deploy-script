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
      async = config['perform_async'].nil? ? true : config['perform_async']

      async ? ExecutionWorker.perform_async(options) : Executor.execute(options)
    end
  end
end