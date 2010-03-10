require 'httparty'

module Nori

  class ActionNotSpecified < StandardError; end

  class Resource
    def initialize(attributes)
      @attributes = attributes
    end

    def self.action(name, attributes)
      @actions ||= {}
      @actions.merge!({name => attributes})
    end

    def self.find(*args)
      raise(ActionNotSpecified) unless @actions[:index]
      options = args.last.is_a?(Hash) ? args.pop : {}
      all(options)
    end

    def self.all(args = {})
      response = Request.perform(
        @actions[:index][:url],
        args,
        @actions[:index][:method] || :get
      )

      response[name.split('::').last.downcase].map{|item| new(item) }
    end
  end

  class Request
    def self.perform(url, args = {}, method = :get)
      HTTParty.send(method, url, :query => args)
    end
  end
end
