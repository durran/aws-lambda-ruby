class HeartbeatLogSubscriber
  include Mongo::Loggable

  def started(event)
    log_debug("#{event.address} | STARTED")
  end

  def succeeded(event)
    log_debug("#{event.address} | SUCCEEDED | #{event.duration}s")
  end

  def failed(event)
    log_debug("#{event.address} | FAILED | #{event.error.class}: #{event.error.message} | #{event.duration}s")
  end

  private

  def logger
    Mongo::Logger.logger
  end

  def format_message(message)
    format("HEARTBEAT | %s".freeze, message)
  end
end
