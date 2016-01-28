module LSQS
  module Actions
    class SendMessage < Base
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
        message = queue.create_message(params)

        builder.MD5OfMessageBody message.md5
        builder.MessageId message.id
      end
    end # SendMessage
  end # Actions
end # LSQS