require 'lib/nori'

module Wakoopa
  include Nori
  
  class Software < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/software.xml'
  end
  
  class Comment < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/comments.xml'
  end
  
  class PlacedComment < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/placed_comments.xml'
  end
  
  class Review < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/reviews.xml'
  end
  
  class Relation < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/relations.xml'
  end
  
  class Team < Resource
    action :index, :url => 'http://api.wakoopa.com/jkreeftmeijer/teams.xml'
  end
end

Wakoopa::Software.all.each {|s| puts s.name}
puts '...'
puts Wakoopa::Comment.all.to_yaml#.each {|s| puts s.name}
  
#class Comment < Base
#    @section = 'comments'
#  end
#  
#  # Wakoopa::PlacedComment
#  #
#  # Extends Wakoopa::Base and passes 'placed_comments' as a @section variable
#  class PlacedComment < Base
#    @section = 'placed_comments'
#  end
#  
#  # Wakoopa::Review
#  #
#  # Extends Wakoopa::Base and passes 'reviews' as a @section variable
#  class Review < Base
#    @section = 'reviews'
#  end
#    
#  # Wakoopa::Relation
#  #
#  # Extends Wakoopa::Base and passes 'relations' as a @section variable
#  class Relation < Base
#    @section = 'relations'
#  end
#  
#  # Wakoopa::Team
#  #
#  # Extends Wakoopa::Base and passes 'teams' as a @section variable
#  class Team < Base
#    @section = 'teams'
#  end
#  