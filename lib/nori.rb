require 'httparty'

module Nori
  class Resource
    def self.action(name, attributes)
      @actions ||= {}
      @actions.merge!({name => attributes})
    end
  end

  class Request
    def self.perform(url, args = {}, method = :get)
      HTTParty.send(method, url, :query => args)
    end
  end
end
