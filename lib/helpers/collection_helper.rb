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
   
    def format_nodes( item, col )
      buff = []
      _format_nodes( buff, item, col )
      buff.join( "\n" )
    end
    
    def _format_nodes( buff, item, col=nil )
      if item.is_a?( Array )
        buff << "<li><ins style=\"background-position:-48px -16px\"></ins><span>#{col} <span class=\"meta\" style=\"color:#c1c1c1\">(#{item.size})</span></span>"
        return buff if item.empty?
        buff << "<ul>"
        count = 0
        item.each do |element|
          _format_nodes( buff, element ) 
          count += 1
        end
        buff << "</ul>"        
        buff << "</li>"
      elsif item.is_a?( Hash )
        buff << "<li><ins style=\"background-position:-48px -16px\"></ins><span>#{col} (#{item.size})</span>"
        return buff if item.empty?
        buff << "<ul>"
        item.each_pair do |key,val|
          _format_nodes( buff, val, key ) 
        end
        buff << "</ul>"
        buff << "</li>"
      else
        buff << "<li><ins></ins><span title=\"#{item.to_s}\">#{truncate(item.to_s,90)} <span class=\"meta\" style=\"color:#c1c1c1\">#{col ? "[#{col} - #{item.class}]" : "[#{item.class}]"}</span></span></li>"
      end      
    end
    
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