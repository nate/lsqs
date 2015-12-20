module LSQS
  module Actions
    class ChangeMessageVisibility < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        name       = params['QueueName']
        visibility = params['VisibilityTimeout']
        receipt    = params['ReceiptHandle']
        queue = queue_list.find(name)
        
        queue.change_message_visibility(receipt, visibility.to_i)

        return
      end
    end # ChangeMessageVisibility
  end # Actions
end # LSQS