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
   
    def back_paths!
      path_ids   = session[:path_ids]
      path_names = session[:path_names]
      
      new_path_ids = path_ids.split( "|" )
      new_path_ids.pop
      session[:path_ids] = new_path_ids.join( "|" )
    
      new_path_names = path_names.split( "|" )
      new_path_names.pop
      session[:path_names] = new_path_names.join( "|" )      
    end
    
    def title_for( path_names )
      tokens = path_names.split( "|" )
      buff = case tokens.length 
        when 2 : "Environment"
        when 3 : "Database"
        else     "Collection"
      end
      
      buff += " <em>#{tokens.last}</em>"
    end
    
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