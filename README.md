# Deployig a Ruby AWS Lambda function with MongoDB

## Setup

### Install Ruby 2.7.0 (Most recent Lambda Ruby version)

```
rbenv install 2.7.0
rbenv use 2.7.0
```

### Create a Gemfile in the project and add the mongo dependency

Gemfile:

```ruby
source 'https://rubygems.org'
gem 'mongo'
```

```
bundle install
```

### Create the lambda function locally and setup cluster access:

db.rb:

```ruby
require 'mongo'

module LambdaFunctions
  extend self

  if !@client
    @client = Mongo::Client.new(ENV['MONGODB_URI'])
    # We ping here to create the initial connection so the client
    # remains connected in the execution environment.
    puts @client.database.command({ ping: 1 }).documents
  end

  def client
    @client
  end
end
```

The function itself MUST be named lambda_function.rb.

lambda_function.rb:

```ruby
require 'db'
require 'json'

def handler(event:, context:)
  {
    event: JSON.generate(event),
    context: JSON.generate(context.inspect),
    count: LambdaFunctions.client[:articles].estimated_document_count
  }
end
```

## Deploy

### Install dependencies

We need to install the mongo dependency against an environment that mimics
the AWS environment so the native bson modules will run.

In the shell:

```
mkdir -p ruby/gems
docker run --rm -v $PWD:/var/layer -w /var/layer lambci/lambda:build-ruby2.7 bundle install --path=ruby/gems
mv ruby/gems/ruby/* ruby/gems/ && rm -rf ruby/gems/2.7.0/cache && rm -rf ruby/gems/ruby
zip -r layer.zip ruby
```

### Create a layer

Create the layer in the web console, uploading the layer.zip we created and
setting the runtime to Ruby 2.7

### Create the function

Create a function with a Ruby 2.7 runtime and change the execution role to the
existing execution role service-role/LambdaRole

### Add the layer to the function

Use the latest version of the layer, should be 1 in this case.

### Add the URI Configuration

Add MONGODB_URI env variable to function.

### Upload the function Zip

```
zip function.zip db.rb lambda_function.rb
```

## Profit

Next steps, automate.
