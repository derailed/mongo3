module Databases
  
  # ---------------------------------------------------------------------------  
  get "/databases/:page" do
    page       = params[:page].to_i || 1
    path_names = session[:path_names]
    tokens     = path_names.split( "|" )
    
    # Could be we have a cltn path. if so adjust for it
    if tokens.size > 3
      tokens.pop
      session[:path_names] = tokens.join( "|") 
      path_names           = session[:path_names]      
      path_ids             = session[:path_ids].split( "|" )
      path_ids.pop
      session[:path_ids]   = path_ids.join( "|" )
    end 
      
puts "DB PATH #{path_names.inspect}"
    @cltns     = options.connection.paginate_db( path_names, page, 10 )
    @back_url  = "/explore/back"
    
    erb :'databases/list'
  end
  
  # ---------------------------------------------------------------------------
  get "/databases/collection/:name/" do
    cltn_name  = params[:name]
    path_names = session[:path_names]
    path_ids   = session[:path_ids]
    
    update_paths!( path_ids + "|" + cltn_name, path_names + "|" + cltn_name )

    redirect "/collections/1"
  end
      
  # ---------------------------------------------------------------------------  
  get "/databases/drop/" do
    path_names = session[:path_names]
    options.connection.drop_db( path_names )
    
    redirect "/explore/back"
  end

  # ---------------------------------------------------------------------------  
  post "/databases/delete/" do
    path = params[:path]    
 
    options.connection.drop_cltn( session[:path_names] + "|" + path )
    
    flash_it!( :info, "Collection #{path} was dropped successfully!" )        
    
    @cltns = options.connection.paginate_db( session[:path_names], 1, 10 )    
  
    erb :'databases/results.js', :layout => false
  end
  
end