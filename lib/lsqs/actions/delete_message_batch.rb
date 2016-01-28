module LSQS
  module Actions
    class DeleteMessageBatch < Base
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

        queue    = queue_list.find(name)
        receipts = params.select do |key, value|
          key.match(/DeleteMessageBatchRequestEntry\.\d+\.ReceiptHandle/)
        end

        deleted = []

        receipts.each do |key, value|
          id = key.split('.')[1]
          queue.delete_message(value)
          deleted << params["DeleteMessageBatchRequestEntry.#{id}.Id"]
        end

        deleted.compact.each do |id|
          builder.DeleteMessageBatchResultEntry do
            builder.Id id
          end
        end
      end
    end # DeleteMessageBatch
  end # Actions
end # LSQS