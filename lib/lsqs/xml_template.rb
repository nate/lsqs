module LSQS
  class XMLTemplate
    attr_reader :template
    
    TEMPLATE_DIR = File.expand_path('../../../config', __FILE__)
    
    def initialize
      xml = File.read("#{TEMPLATE_DIR}/template.xml.liquid")
      @template = Liquid::Template.parse(xml)
    end
    
    ##
    # Renders the XML that is required as a body response.
    #
    # @param [Actions::Base] action
    #
    # @return [String]
    #
    def render(action)
      options = { 
        'action'     => action.name,
        'content'    => action.to_xml,
        'request_id' => request_id
      }
      
      template.render(options)
    end
    
    ##
    # Renders the XML that is required for an error response
    #
    # @param [String] error
    #
    # @return [String]
    #
    def render_error(error)
      options = {
        'error'      => error,
        'request_id' => request_id
      }
      
      template.render(options)
    end
    
    ##
    # Generates a request ID.
    #
    # @return [String]
    #
    def request_id
      SecureRandom.uuid
    end
  end # XMLTemplate
end #LSQS