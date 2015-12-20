module LSQS
  module Actions
    class DeleteQueue < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        name  = params['QueueName']
        queue = queue_list.delete(name)
        return
      end
    end # DeleteQueue
  end # Actions
end # LSQS