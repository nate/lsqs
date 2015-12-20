module LSQS
  module Actions
    class DeleteMessage < Base
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
        
        receipt = params['ReceiptHandle']
        queue.delete_message(receipt)
        return
      end
    end # DeleteMessage
  end # Actions
end # LSQS