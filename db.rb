require 'mongo'

module LambdaFunctions
  extend self

  if !@client
    @client = Mongo::Client.new(ENV['MONGODB_URI'])
    # We ping here to create the initial connection so the client
    # remains connected in the execution environment.
    @client.database.command({ ping: 1 })
  end

  def client
    @client
  end
end
