module LSQS
  class ActionRouter
    class ActionError < NameError; end
    attr_reader :queue_list
    
    ##
    # @param [LSQS::QueueList] queue_list
    #
    def initialize(queue_list)
      @queue_list = queue_list
    end
    
    def distribute(action_name, options)
      if LSQS::Actions.const_defined?(action_name)
        action = LSQS::Actions.const_get(action_name).new(queue_list)
        queue_list.query do
          action.perform(options)
        end
        
        return action
      else
        raise ActionError, "undefined action `#{action_name}`"
      end
    end
  end # ActionRouter
end # LSQS