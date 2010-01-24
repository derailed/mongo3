module PathHelper
  helpers do
    
    # looking at zone path?    
    def zone_path?( path )
      path.split( "|" ).size == 1
    end

    # looking at db path?    
    def db_path?( path )
      path.split( "|" ).size == 3
    end

    # looking at cltn path?
    def cltn_path?( path )
      path.split( "|" ).size == 4
    end
    
    def reset_paths!
      session[:path_ids]   = "home"
      session[:path_names] = "home"
    end
    
    def update_paths!( path_ids, path_names )
      session[:path_ids]   = path_ids
      session[:path_names] = path_names
    end
    
    # Pop paths 1 level
    def back_paths!
      path_ids     = session[:path_ids]
      new_path_ids = path_ids.split( "|" )
      new_path_ids.pop
    
      path_names = session[:path_names]    
      new_path_names = path_names.split( "|" )
      new_path_names.pop
      
      update_paths!( new_path_ids.join( "|" ), new_path_names.join( "|" ) )
    end
    
    # compute title from path    
    def title_for( path_names )
      tokens = path_names.split( "|" )
      buff = case tokens.size
        when 2 
          "zone"
        when 3 
          "database"
        else     
          "collection"
      end
      db = tokens.size > 3 ? "<span class=\"ctx\">#{tokens[2]}</span>." : ""
      "<p class=\"ctx\" style=\"text-align:center;font-size:0.8em\">#{db}#{tokens.last}</p>"
    end
    
  end
end