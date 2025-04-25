require 'logger'
require 'faraday'

module Services
  class Nytimes

    API_URL = 'https://www.nytimes.com/svc/games/state/wordleV2/latests'
    
    def initialize(cookie: ENV['NYTIMES_COOKIE'], logger: Logger.new($stdout))
      raise ArgumentError, 'NYTIMES_COOKIE is not set' if cookie.nil? || cookie.empty?

      @logger = logger

      @conn = Faraday.new(url: API_URL) do |f|
        f.response :json
        f.options.timeout = 5
        f.headers['Cookie'] = cookie
      end
    end


    def get_user_stats
      @logger.info "Fetching NYT stats..."
      response = @conn.get

      if response.success?
        @logger.debug "Response: #{response.body}"
        stats = response.body 
        return {
          wordle_streak: stats&.dig('player', 'stats','wordle', 'calculatedStats', 'currentStreak'),
          wordle_max_streak: stats&.dig('player', 'stats','wordle', 'calculatedStats', 'maxStreak'),
        }
      else
        @logger.error "Error fetching NYT stats: #{response.status}"
        return nil
      end
    rescue Faraday::Error => e
      @logger.error "HTTP error: #{e.message}"
      @logger.error "Response: #{e.response[:status]}"
      @logger.error "Response body: #{e.response[:body]}"
      return nil
    end
  end
end