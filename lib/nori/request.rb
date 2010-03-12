require 'httparty'

module Nori
  class Request
    def self.perform(url, args = {}, http_method = :get)
      HTTParty.send(http_method, url, :query => args)
    end
  end
end
