module ExploreHelper 
  
  helpers do    
    
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