module LSQS
  module Actions
    class PurgeQueue < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        name  = params['QueueName']
        queue = queue_list.find(name)
        queue.purge
        return
      end
    end # PurgeQueue
  end # Actions
end # LSQS