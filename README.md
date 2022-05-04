# Deploying a Ruby AWS Lambda function with MongoDB

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
    @client.database.command({ ping: 1 })
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

<img width="865" alt="Create Layer" src="https://user-images.githubusercontent.com/9030/166814767-08721e76-3de0-4c38-878e-213978441a9e.png">

### Create the function

Create a function with a Ruby 2.7 runtime and change the execution role to the
existing execution role service-role/LambdaRole

<img width="1346" alt="Create Function" src="https://user-images.githubusercontent.com/9030/166814880-afe9a709-71b7-406f-9f00-c2c0153f6511.png">

### Add the layer to the function

Use the latest version of the layer, should be 1 in this case.

<img width="859" alt="Add Layer" src="https://user-images.githubusercontent.com/9030/166814996-06830740-3f2f-484f-a804-847390cbcb0b.png">

### Add the URI Configuration

Add MONGODB_URI env variable to function.

<img width="851" alt="Edit URI" src="https://user-images.githubusercontent.com/9030/166815045-44e384bd-6b27-44b7-a23c-7a2a70d4510b.png">

### Upload the function Zip

```
zip function.zip db.rb lambda_function.rb
```

<img width="871" alt="Upload" src="https://user-images.githubusercontent.com/9030/166815381-8920a051-4446-4c3e-984a-afc3ddb55301.png">

## Profit

Next steps, automate.
