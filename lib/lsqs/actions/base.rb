module LSQS
  module Actions
    class Base
      attr_accessor :queue_list
      attr_reader :builder
      
      def initialize(queue_list)
        @queue_list = queue_list
      end
          
      ##
      # Returns the name of the class without namespacing.
      #
      # @return [String]
      #
      def name
        return self.class.name.split('::').last
      end
      
      ##
      # Initializes a XML builder.
      #
      # @return [Builder::XmlMarkup]
      #
      def builder
        @builder ||= Builder::XmlMarkup.new(:indent => 2)
      end
      
      ##
      # Outputs XML from the builder as a string.
      #
      # @return [String]
      #
      def to_xml
        builder.target!
      end
      
      ##
      # Builds the URL of the queue.
      #
      # @param [String] base_url
      # @param [String] queue_name
      
      # @return [String]
      #
      def build_url(base_url, queue_name)
        return "#{base_url}/#{queue_name}"
      end
    end # Base
  end # Actions
end # LSQS