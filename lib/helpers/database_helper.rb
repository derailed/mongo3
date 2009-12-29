module DatabaseHelper
  helpers do
      
    def db_title
      paths = session[:path_names].split( "|" )
      return context_for( paths ), paths.last
    end
   
    def context_for( paths )
      case paths.size
        when 2 : "zone"
        when 3 : "database"
        else     "collection"
      end      
    end    
  end  
end