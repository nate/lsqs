module LSQS
  class Message
    attr_reader :body, :id, :md5
    attr_accessor :visibility_timeout

    def initialize(options = {})
      @body = options['MessageBody']
      @id   = options.fetch('Id') { SecureRandom.uuid }
      @md5  = options.fetch('MD5') { Digest::MD5.hexdigest(body) }
    end

    def attributes
      {
        "MessageBody" => body,
        "Id"          => id,
        "MD5"         => md5,
      }
    end
    
    ##
    # Check if a message's visibility has timed out.
    #
    # @return [TrueClass|FalseClass]
    #
    def expired?
      visibility_timeout.nil? || visibility_timeout < Time.now
    end
    
    ##
    # Sets the time when the message should expire.
    #
    # @param [Fixnum] seconds
    #
    # @return [Time]
    #
    def expire_in(seconds)
      @visibility_timeout = Time.now + seconds
    end
    
    ##
    # Resets the visibility time of the message.
    #
    # @return [NilClass]
    #
    def expire
      @visibility_timeout = nil
    end
  end # Message
end # LSQS