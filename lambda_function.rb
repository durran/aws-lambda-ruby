require 'db'
require 'json'

def handler(event:, context:)
  {
    event: JSON.generate(event),
    context: JSON.generate(context.inspect),
    count: LambdaFunctions.client[:articles].estimated_document_count
  }
end
