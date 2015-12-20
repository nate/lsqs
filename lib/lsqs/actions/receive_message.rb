module LSQS
  module Actions
    class ReceiveMessage < Base
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
        messages = queue.get_messages(params)
        
        messages.each do |receipt, message|
          builder.Message do
            builder.MessageId message.id
            builder.ReceiptHandle receipt
            builder.MD5OfBody message.md5
            builder.Body message.body
          end
        end
      end
    end # ReceiveMessage
  end # Actions
end # LSQS