class ExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(options)
    raw_commands = options.delete('commands').join(' && ')
    host = options.delete('host')
    user = options.delete('user')
    server_data = []

    Net::SSH.start(host, user, **options.transform_keys(&:to_sym)) do |ssh|
      channel = ssh.open_channel do |ch|
        puts "Executing commands on server #{host}..."
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
      puts "Done! Check logs in lib/log/#{host}.log"
      File.open($root.join('lib', 'log', "#{host}.log"), "w+") { |file| file.write(server_data.join)}
    end
  end
end