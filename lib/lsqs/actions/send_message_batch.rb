module LSQS
  module Actions
    class SendMessageBatch < Base
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
        
        messages = params.select do |key, value| 
          key.match(/SendMessageBatchRequestEntry\.\d+\.MessageBody/)
        end
        
        result = {}

        messages.each do |key, value|
          id      = key.split('.')[1]
          msg_id  = params["SendMessageBatchRequestEntry.#{id}.Id"]
          delay   = params["SendMessageBatchRequestEntry.#{id}.DelaySeconds"]
          message = queue.create_message(
            'MessageBody' => value, 
            'DelaySeconds' => delay
          )
          result[msg_id] = message
        end

        result.each do |msg_id, message|
          builder.SendMessageBatchResultEntry do
            builder.MD5OfMessageBody message.md5
            builder.MessageId message.id
            builder.Id msg_id
          end
        end
      end
    end # SendMessageBatch
  end # Actions
end # LSQS