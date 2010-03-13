module Nori
  class Resource
    def initialize(attributes)
      @attributes = attributes
    end

    def method_missing(method)
      return @attributes[method.to_s] if @attributes[method.to_s]
      super
    end
    
    def save
      Request.perform(self.class.url(:create), @attributes, self.class.http_method(:create))
    end

    def self.action(name, attributes)
      @actions ||= {}
      @actions.merge!({name => attributes})
    end

    def self.find(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      action = args.first == :all ? :index : :show

      raise(ActionNotSpecified) unless @actions[action]

      response = Request.perform(url(action), options, http_method(action))
      
      raise(ParentNodeNotFound, "Couldn't find `#{parent_node(action)}` in #{response.to_yaml}") unless response[parent_node(action)]
      
      if action == :index
        response[parent_node(:index)].map{|item| new(item) }
      else
        new response[parent_node(:show)]
      end      
    end

    def self.all(args = {})
      find(:all, args)
    end

    def self.parent_node(action)
      super || name.split('::').last.downcase
    end

    def self.http_method(action)
      super || (action == :create ? :post : :get)
    end

    def self.parameter_action(parameter, action)
      @actions[action][parameter]
    end

    def self.method_missing(method, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      if method.to_s.match(/^find_(all_)?by_([_a-zA-Z]\w*)$/)
        attributes = {}
        $2.split('_and_').each do |key|
          attributes.merge!({key.to_sym => args.shift})
        end        
        return find(:all, attributes.merge(options)) if $1
        return find(attributes.merge(options))
      end

      parameter_action(method, *args)
    end
  end
end
