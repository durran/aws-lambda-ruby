class HeartbeatLogSubscriber
  include Mongo::Loggable

  def started(event)
    log_info("#{event.address} | STARTED")
  end

  def succeeded(event)
    log_info("#{event.address} | SUCCEEDED | #{event.duration}s")
  end

  def failed(event)
    log_info("#{event.address} | FAILED | #{event.error.class}: #{event.error.message} | #{event.duration}s")
  end

  private

  def logger
    Mongo::Logger.logger
  end

  def format_message(message)
    format("HEARTBEAT | %s".freeze, message)
  end
end

class CommandLogSubscriber
  include Mongo::Loggable

  def started(event)
    log_info("#{prefix(event)} | STARTED | #{format_command(event.command)}")
  end

  def succeeded(event)
    log_info("#{prefix(event)} | SUCCEEDED | #{event.duration}s")
  end

  def failed(event)
    log_info("#{prefix(event)} | FAILED | #{event.message} | #{event.duration}s")
  end

  private

  def logger
    Mongo::Logger.logger
  end

  def format_command(args)
    begin
      args.inspect
    rescue Exception
      '<Unable to inspect arguments>'
    end
  end

  def format_message(message)
    format("COMMAND | %s".freeze, message)
  end

  def prefix(event)
    "#{event.address.to_s} | #{event.database_name}.#{event.command_name}"
  end
end
