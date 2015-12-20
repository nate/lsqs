module LSQS
  module Actions
    class GetQueueUrl < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        base_url = params['base_url']
        name     = params['QueueName']
        
        queue = queue_list.delete(name)
        
        url = build_url(base_url, name)

        builder.QueueUrl build_url(base_url, name)
      end
    end # GetQueueUrl
  end # Actions
end # LSQS