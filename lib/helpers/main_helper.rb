module MainHelper  
 helpers do   
      
    def stylesheets( styles )
      buff = []
      styles.each do |style|
        buff << "<link rel=\"stylesheet\" href=\"#{v_styles( style )}\" type=\"text/css\" media=\"screen\" />"
      end
      buff.join( "\n" )
    end
    
    def javascripts( scripts )
      buff = []
      scripts.each do |script|
        buff << "<script src=\"#{v_js( script )}\" type=\"text/javascript\"></script>"
      end
      buff.join( "\n" )      
    end
          
    def v_styles(stylesheet)
      "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.public, "stylesheets", "#{stylesheet}.css")).to_i.to_s
    end
    
    def v_js(js)
      "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
    end
      
    def zone_locator
      locator = session[:path_names].split( "|" )[1]
      "<p class=\"ctx\"><span>zone</span>#{locator}</p>"
    end
      
    def truncate(text, length = 30, truncate_string = "...")
      return "" if text.nil?
      l = length - truncate_string.size
      text.size > length ? (text[0...l] + truncate_string).to_s : text
    end
      
    def align_for( value )
      return "right" if value.is_a?(Fixnum)
      "left"
    end
    
    # Add thousand markers
    def format_number( value )
      return value.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,') if value.instance_of?(Fixnum)
      value
    end
           
    def display_info( info )
      return info if info.is_a?( String )
      if info.is_a?( Hash )
        @info = info
        partial :'explore/dump_hash'
      elsif info.is_a?( Array )
        @info = info
        partial :'explore/dump_array'
      else
        format_number( info )
      end
    end
    
    def partial( page, options={} )
      if page.to_s.index( /\// )
        page = page.to_s.gsub( /\//, '/_' ) 
      else 
        page = "_" + page.to_s
      end
      erb page.to_sym, options.merge!( :layout => false )
    end
   
    JS_ESCAPE_MAP = 
    {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'" 
    }   
    def escape_javascript(javascript)
      if javascript
         javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
         ''
      end
    end    
  end  
end