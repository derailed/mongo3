module ExploreHelper 
  
  helpers do    

    # looking at zone path?    
    def zone_path?( path )
      path.split( "|" ).size == 1
    end
    
    # compute legend title
    def legend_title( path )
      path.split( "|" ).last      
    end
    
    def path_type( path )
      tokens = path.split( "|" )
      case tokens.length 
        when 1 
          "zone"
        when 2 
          "database"
        else     
          "collection"
      end            
    end
    
    # compute legend from given path.
    def legend_for( path, count )
     "#{path_type(path)}s(<span id='count'>#{count}</span>)"
    end    
  end
  
end