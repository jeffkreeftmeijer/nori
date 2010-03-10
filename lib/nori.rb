require 'httparty'

module Nori

  class ActionNotSpecified < StandardError; end

  class Resource
    def initialize(attributes)
      @attributes = attributes
    end

    def method_missing(method)
      return @attributes[method.to_s] if @attributes[method.to_s]
      super
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
      response = Request.perform(url(:index), args, http_method(:index))
      response[parent_node(:index)].map{|item| new(item) }
    end

    def self.parent_node(action)
      super || name.split('::').last.downcase
    end

    def self.http_method(action)
      super || :get
    end

    def self.action_parameter(action, parameter)
      @actions[action][parameter]
    end

    def self.method_missing(method, *args)
      action_parameter(*args, method)
    end
  end

  class Request
    def self.perform(url, args = {}, http_method = :get)
      HTTParty.send(http_method, url, :query => args)
    end
  end
end
