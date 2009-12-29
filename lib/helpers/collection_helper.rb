require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

module WillPaginate::ViewHelpers
  class LinkRenderer
    def url( page )
      "#{@options[:params][:url]}/#{page}"
    end
  end
end


module CollectionHelper

 helpers do
   include WillPaginate::ViewHelpers::Base   
   
   # format indexes to key:orientation
   def format_index( pair )
     buff = []
     buff << pair.first
     buff << orientation( pair.last )
     buff.join( ":" )
  end
  
  # converts orientation to human
  def orientation( value )
    return "id" if value.is_a?(Mongo::ObjectID)
    case( value.to_i )
      when Mongo::ASCENDING  : "asc"
      when Mongo::DESCENDING : "desc"
      else                     "n/a"
    end
  end

 end
end