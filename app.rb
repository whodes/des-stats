require 'sinatra/base'
require 'redis'
require 'logger'

require_relative 'config'
require_relative 'services/stats'

class App < Sinatra::Application

  configure do
    config = AppConfig.setup
    set :redis, AppConfig.redis_connection(config[:redis_url])
    set :logger, AppConfig.logger
    set :environment, config[:environment].to_sym
    set :cors_allowed_origin, config[:cors_allowed_origin]
    logger.debug config
  end

  before do
    headers['Access-Control-Allow-Origin'] = settings.cors_allowed_origin
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
  end

  options '*' do
    response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
    response.headers['Access-Control-Allow-Headers'] =
      'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  end

  helpers do
    def logger
      settings.logger
    end
  end

  get '/stats' do
    cached = settings.redis.get('stats')

    if cached
      logger.info "Pulling from the cache 🫙"
      content_type :json
      return cached
    else
      logger.info "Nothing in cache, fetching fresh data 📡"
      stats = set_cache
      content_type :json
      return stats.to_json
    end
  end

  private

  def set_cache
    begin
      stats_service = Services::Stats.new(logger: logger)
      stats = stats_service.get_user_stats
      settings.redis.setex('stats', 24 * 60 * 60, stats.to_json)
      return stats
    rescue StandardError => e
      logger.error "Error fetching stats: #{e.message}"
      return { error: 'Failed to fetch stats' }
    end
  end
  
end