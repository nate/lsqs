module LSQS
  class ErrorHandler
    ERROR_LIST = {
      'AccessDenied'                => 403,
      'AuthFailure'                 => 401,
      'ConflictingQueryParameter'   => 400,
      'InternalError'               => 500,
      'InvalidAccessKeyId'          => 401,
      'InvalidAction'               => 400,
      'InvalidAddress'              => 404,
      'InvalidAttributeName'        => 400,
      'InvalidHttpRequest'          => 400,
      'InvalidMessageContents'      => 400,
      'InvalidParameterCombination' => 400,
      'InvalidParameterValue'       => 400,
      'InvalidQueryParameter'       => 400,
      'InvalidRequest'              => 400,
      'InvalidSecurity'             => 403,
      'InvalidSecurityToken'        => 400,
      'MalformedVersion'            => 400,
      'MessageTooLong'              => 400,
      'MessageNotInflight'          => 400,
      'MissingClientTokenId'        => 403,
      'MissingCredentials'          => 401,
      'MissingParameter'            => 400,
      'NoSuchVersion'               => 400,
      'NonExistentQueue'            => 400,
      'NotAuthorizedToUseVersion'   => 401,
      'QueueDeletedRecently'        => 400,
      'QueueNameExists'             => 400,
      'ReadCountOutOfRange'         => 400,
      'ReceiptHandleIsInvalid'      => 400,
      'RequestExpired'              => 400,
      'RequestThrottled'            => 403,
      'ServiceUnavailable'          => 503,
      'X509ParseError'              => 400
    }

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call env
      rescue => error
        xml = Builder::XmlMarkup.new(:index => 2)

        status = ERROR_LIST[error.message] || 500


        xml.ErrorResponse do
          xml.Error do
            xml.Type error.message
            xml.Code status
            xml.Message error.to_s
            xml.Detail
          end
        end

        [status, {}, [LSQS.template.render_error(xml)]]
      end
    end
  end # ErrorHandler
end # LSQS