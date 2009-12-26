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
  end
  
end