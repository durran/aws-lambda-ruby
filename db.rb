require 'mongo'
require 'subscriber'

module LambdaFunctions
  extend self

  if !@client
    @client = Mongo::Client.new(ENV['MONGODB_URI'])
   
    heartbeat_subscriber = HeartbeatLogSubscriber.new
    command_subscriber = CommandLogSubscriber.new
    @client.subscribe(Mongo::Monitoring::SERVER_HEARTBEAT, heartbeat_subscriber)
    @client.subscribe(Mongo::Monitoring::COMMAND, command_subscriber)
    
    # We ping here to create the initial connection so the client
    # remains connected in the execution environment.
    @client.database.command({ ping: 1 })
  end

  def client
    @client
  end
end
