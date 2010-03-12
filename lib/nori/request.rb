require 'httparty'

module Nori
  class Request
    def self.perform(url, args = {}, http_method = :get)
      HTTParty.send(
        http_method,
        url.gsub(/\{(\w+)\}/) { args.delete($1.to_sym) },
        :query => args
      )
    end
  end
end
