module LSQS
  module Actions
    class CreateQueue < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        name  = params['QueueName']
        queue = queue_list.create(name, params)

        base_url = params['base_url']
        url = build_url(base_url, name)

        builder.QueueUrl build_url(base_url, name)
      end
    end # CreateQueue
  end # Actions
end # LSQS