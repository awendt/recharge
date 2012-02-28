require 'sinatra/base'
require 'dalli'

module Sinatra
  module Cache
    module Helpers
      def cache(name, options = {}, &block)
        if cached_fragment = settings.cache.get(name)
          cached_fragment
        else
          tmp = block.call
          settings.cache.set(name, tmp)
          tmp
        end
      end
    end

    def self.registered(app)
      app.helpers Cache::Helpers
      app.set :cache, ::Dalli::Client.new
    end
  end

  register Cache
end
