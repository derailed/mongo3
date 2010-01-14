require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

# BOZO !! Refact helpers...
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
   
    # Attempts to format an attribute to some human readable format
    def format_value( value )
      if value.is_a?( Fixnum)
        value.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
      elsif value.is_a?(Hash)
        buff = []
        value.each_pair { |k,v| buff << "#{k}:#{format_value(v)}"}
        buff.join( ", " )
      elsif value.is_a?(Array)
        (value.empty? ? "[]" : value.join(", "))
      else
        value
      end        
    end
        
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
        when Mongo::ASCENDING
          "asc"
        when Mongo::DESCENDING  
          "desc"
        else                    
          "n/a"
        end
    end
  end
end