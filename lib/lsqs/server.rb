module LSQS
  class Server < Sinatra::Base
    configure do
      set :dump_errors, false
      set :raise_errors, true
      set :show_exceptions, false
      
      use LSQS::ErrorHandler
    end
    
    helpers do
      
      ##
      # Gets the action that was requested.
      #
      # @return [String]
      #
      def action
        params['Action']
      end
      
      ##
      # Retrieves a XML template and renders it.
      #
      # @param [LSQS::Actions::Base] action
      #
      # @return [String]
      # 
      def render(action)
        LSQS.template.render(action)
      end
      
      ##
      # Returns the base URL of the server.
      #
      # @return [String]
      #
      def base_url
        request.base_url
      end
    end
    
    post '/' do
      params['base_url'] = base_url
      
      result = LSQS.router.distribute(action, params)
  
      return {:body => render(result)}.to_json
    end
    
    # To keep the Amazon convention the queue name is stored
    # in params['QueueName']
    post "/:QueueName" do
      result = LSQS.router.distribute(action, params)
      
      return {:body => render(result)}.to_json
    end
  end # Server
end # LSQS