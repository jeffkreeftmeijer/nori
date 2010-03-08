module Nori
  class Resource
    def self.action(name, attributes)
      (@actions ||= {}).merge!({name => attributes})
    end
  end
end