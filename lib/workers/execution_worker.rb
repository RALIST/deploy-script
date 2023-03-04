class ExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(options)
    Executor.execute(options)
  end
end