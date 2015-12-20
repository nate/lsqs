module LSQS
  module Actions
    class ListQueues < Base
      ##
      # Performs the specific action.
      #
      # @param [Hash] params
      #
      # @return [String]
      #
      def perform(params)
        base_url = params['base_url']
        
        queues = queue_list.inspect(params)
        
        queues.each do |queue|
          builder.QueueUrl build_url(base_url, queue)
        end
      end
    end # ListQueues
  end # Actions
end # LSQS