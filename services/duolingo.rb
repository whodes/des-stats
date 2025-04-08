require 'faraday'
require 'json'
require 'logger'

module Services
  class Duolingo

    
    # API endpoint for Duolingo user info
    BASE_URL = 'https://www.duolingo.com/2017-06-30/users'

    attr_accessor :user_id


    def initialize(user_id: ENV['DUOLINGO_USER_ID'], logger: Logger.new($stdout))
      raise ArgumentError, 'DUOLINGO_USER_ID is not set' if user_id.nil? || user_id.empty?
      
      @logger = logger
      @user_id = user_id
      @conn = Faraday.new(
        url: "#{BASE_URL}/#{@user_id}",
        params: { fields: 'streak' },
        headers: { 'Content-Type' => 'application/json' }
      ) do |f|
        f.response :json
      end
    end
    

    def get_user_stats
      @logger.info "Fetching Duolingo stats..."
      response = @conn.get

      if response.success?
        @logger.debug "Response: #{response.body}"
        return response.body
      else
        @logger.error "Error fetching Duolingo stats: #{response.status}"
        return nil 
      end
    resuce Faraday::Error => e
      @logger.error "HTTP error: #{e.message}"
      return nil
    end
  end
end