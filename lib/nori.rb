module Nori
  class Resource
    def self.action(name, attributes)
      @actions ||= {}
      @actions.merge!({name => attributes})
    end
  end
end
