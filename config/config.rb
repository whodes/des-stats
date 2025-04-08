require 'redis'
require 'logger'

module AppConfig
  def self.setup
    {
      redis_url: ENV['REDIS_URL'] || 'redis://localhost:6379',
      log_level: ENV['LOG_LEVEL'] || (ENV['RACK_ENV'] == 'development' ? 'debug' : 'info'),
      environment: ENV['RACK_ENV'] || 'development',
      cors_allowed_origin: ENV['CORS_ALLOWED_ORIGIN'] || '*',
    }
  end


  def self.redis_connection(redis_url)
    Redis.new(url: redis_url)
  end

  def self.logger
    Logger.new(STDOUT).tap do |logger|
      logger.level = Logger.const_get(self.setup[:log_level].upcase)
    end
  end
end