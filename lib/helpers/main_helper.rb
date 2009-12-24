module MainHelper

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
  
 helpers do   
   
    def display_info( info )
      return info if info.is_a?( String )
      if info.is_a?( Hash )
        @info = info
        partial :dump_hash
      elsif info.is_a?( Array )
        @info = info
        partial :dump_array
      else
        info
      end
    end
    
    def partial( page, options={} )
      erb "_#{page}".to_sym, options.merge!( :layout => false )
    end
   
    def escape_javascript(javascript)
      if javascript
         javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
         ''
      end
    end
    
  end
  
end