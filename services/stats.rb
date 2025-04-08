require 'logger'

require_relative 'duolingo'
require_relative 'nytimes'

module Services
  class Stats

    def initialize(logger: Logger.new($stdout))
      @logger = logger
      @duolingo = Services::Duolingo.new(logger: @logger)
      @nytimes = Services::Nytimes.new(logger: @logger)
    end


    def get_user_stats
      @logger.info "Fetching user stats..."
      duolingo_stats = @duolingo.get_user_stats
      nytimes_stats = @nytimes.get_user_stats
      {
        duolingo: duolingo_stats&.dig('streak'),
        nytimes: {
          wordle: nytimes_stats&.dig('wordle_streak'),
        }
      }
    end

  end
end