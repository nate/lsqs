module LSQS
  class Queue
    attr_accessor :name, :messages, :in_flight, :attributes, :monitor
    
    DEFAULT_TIMEOUT = 30
    
    def initialize(name, params = {})
      @name       = name
      @attributes = params.fetch('Attributes'){Hash.new}
      @monitor    = Monitor.new
      @messages   = []
      @in_flight  = {}
      @timeout    = true
      
      check_timeout
    end
    
    ##
    # Sets the default timeout of a queue. It takes the value from the
    # attributes, if it is set, otherwise it uses the `DEFAULT_TIMEOUT`
    # constant.
    #
    # @return [Fixnum]
    #
    def visibility_timeout
      attributes['VisibilityTimeout'] || DEFAULT_TIMEOUT
    end
    
    ##
    # Creates a new message in the queue.
    #
    # @param [Hash] options
    #
    # @return [Message]
    #
    def create_message(options = {})
      lock do
        message = Message.new(options)
        @messages << message
        return message
      end
    end
    
    ##
    # Gets a number of messages based on the MaxNumberOfMessages field.
    #
    # @param [Hash] options
    #
    # @return [Hash]
    #
    def get_messages(options = {})
      number_of_messages = options.fetch('MaxNumberOfMessages'){1}.to_i

      raise 'ReadCountOutOfRange' if number_of_messages > 10

      result = {}

      lock do
        amount = number_of_messages > size ? size : number_of_messages

        amount.times do
          message             = messages.delete_at(rand(size))
          message.expire_in(visibility_timeout)
          receipt             = generate_receipt
          @in_flight[receipt] = message
          result[receipt]     = message
        end
      end

      return result
    end
    
    ##
    # Deletes a message from the messages that are in-flight.
    #
    # @param [String] receipt
    #
    def delete_message(receipt)
      lock do
        in_flight.delete(receipt)
      end
    end
    
    ##
    # Deletes all messages in queue and in flight.
    #
    def purge
      lock do
        @messages  = []
        @in_flight = {}
      end
    end
    
    ##
    # Returns the amount of messages in the queue.
    #
    # @return [Fixnum]
    #
    def size
      messages.size
    end
    
    ##
    # Generates a hex receipt for the message
    #
    # @return [String]
    #
    def generate_receipt
      SecureRandom.hex(16)
    end
    
    ##
    # Change the visibility of a message that is in flight. If visibility
    # is set to 0, put back in the queue.
    #
    # @param [String] receipt
    # @param [Fixnum] seconds
    #
    def change_message_visibility(receipt, seconds)
      lock do
        message = @in_flight[receipt]
        raise 'MessageNotInflight' unless message

        if seconds == 0
          message.expire
          @messages << message
          delete_message(receipt)
        else
          message.expire_in(seconds)
        end
      end
    end
    
    ##
    # Checks if in-fligh messages need to be put back in the queue.
    # 
    def timeout_messages
      lock do
        in_flight.each do |key, message|
          if message.expired?
            message.expire
            @messages << message
            delete_message(key)
          end
        end
      end
    end
    
    protected
    
    ##
    # Initializes a thread that checks every 5 seconds if messages need
    # to be put back from flight to the message queue.
    #
    def check_timeout
      Thread.new do
        while @timeout
          unless in_flight.empty?
            timeout_messages
          end
          sleep(5)
        end
      end
    end
    
    ##
    # Locks a block, in order to ensure that there is no conflict if more than
    # one processes try to access the object.
    # 
    def lock
      @monitor.synchronize do
        yield
      end
    end
  end # Queue
end # LSQS