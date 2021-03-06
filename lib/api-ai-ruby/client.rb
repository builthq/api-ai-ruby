require 'securerandom'

module ApiAiRuby
  class Client
    attr_accessor :client_access_token, :timeout_options
    attr_writer :user_agent, :api_version, :api_lang, :api_base_url, :api_session_id

    # Initializes a new Client object
    # @param options [Hash]
    # @return [ApiAiRuby::Client]
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      if !(options.key?  :api_session_id)
        @api_session_id = SecureRandom.uuid
      end

      yield(self) if block_given?
    end

    # @return [String]
    def user_agent
      @user_agent ||= "ApiAiRubyGem/#{ApiAiRuby::Constants::VERSION}"
    end

    def api_base_url
      @api_base_url ||= ApiAiRuby::Constants::DEFAULT_BASE_URL
    end

    def api_lang
      @api_lang ||= ApiAiRuby::Constants::DEFAULT_CLIENT_LANG
    end

    def api_version
      @api_version ||= ApiAiRuby::Constants::DEFAULT_API_VERSION
    end

    def api_session_id
      @api_session_id
    end

    # @return [Hash]
    def credentials
      {
          client_access_token: client_access_token,
      }
    end

    # @return [Boolean]
    def credentials?
      credentials.values.all?
    end

    def text_request (query = '', options = {})
      raise ApiAiRuby::ClientError.new('Credentials missing') if !credentials?
      options[:query] = query
      ApiAiRuby::TextRequest.new(self, options).perform
    end

    # @param event_name [String]
    # @param data [Object]
    # @param options [Object]
    def event_request (event_name = '', data = {}, options = {})
      raise ApiAiRuby::ClientError.new('Credentials missing') if !credentials?
      options[:event] = {
          name: event_name,
          data: data
      }
      ApiAiRuby::EventRequest.new(self, options).perform
    end

    def voice_request(file_stream, options = {})
      raise ApiAiRuby::ClientError.new('Credentials missing') if !credentials?
      options[:file] = file_stream
      ApiAiRuby::VoiceRequest.new(self, options).perform
    end

    def user_entities_request
      ApiAiRuby::UserEntitiesRequest.new(self);
    end

  end
end