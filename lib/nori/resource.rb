module Nori
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

    def self.parameter_action(parameter, action)
      @actions[action][parameter]
    end

    def self.method_missing(method, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      if method.to_s.match(/^find_all_by_([_a-zA-Z]\w*)$/)
        attributes = {}
        $1.split('_and_').each do |key|
          attributes.merge!({key.to_sym => args.shift})
        end
        return all(attributes.merge(options))
      end

      parameter_action(method, *args)
    end
  end
end
