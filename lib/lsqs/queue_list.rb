module LSQS
  class QueueList
    include MonitorMixin

    attr_accessor :queues
    
    def initialize
      super
      @queues  = {}
    end
    
    ##
    # Purges the current queue list.
    #
    # @return [Hash]
    #
    def purge
      @queues = {}
    end
    
    ##
    # Creates a new queue, if it doesn't exist already.
    #
    # @param [String] name
    # @param [Hash] options
    #
    # @return [LSQS::Queue]
    #
    def create(name, options = {})
      unless queues[name]
        @queues[name] = Queue.new(name, options)
      else
        raise 'QueueNameExists'
      end
    end
    
    ##
    # Returns the names of the existing queues.
    #
    # @param [Hash] options
    #
    # @return [Array]
    #
    def inspect(options = {})
      if prefix = options['QueueNamePrefix']
        queues.select { |name, queue| name.start_with?(prefix) }.values.map(&:name)
      else
        queues.values.map(&:name)
      end
    end
    
    ##
    # Searches for a queue in the list by name.
    # If it doesn't find it, it creates it.
    #
    # @param [String] name
    #
    # @return [Queue]
    #
    def find(name)
      if queue = queues[name]
        return queue
      else
        raise 'NonExistentQueue'
      end
    end
    
    ##
    # Deletes a queue if it exists.
    #
    # @param [name]
    #
    def delete(name)
      if queues[name]
        queues.delete(name)
      else
        raise 'NonExistentQueue'
      end
    end
    
    ##
    # Queries the list of queues.
    #
    def query
      synchronize do
        yield
      end
    end
  end # QueueList
end # LSQS