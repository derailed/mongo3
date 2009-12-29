module Databases
  
  # ---------------------------------------------------------------------------  
  get "/databases/:page" do
    page       = params[:page].to_i || 1
    path_names = session[:path_names]
          
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
    
    options.connection.drop_cltn( path )
    
    flash_it!( :info, "Collection #{path.split('|').last} was dropped successfully!" )        
    
    @cltns = options.connection.paginate_db( session[:path_names], 1, 10 )    
  
    erb :'databases/results.js', :layout => false
  end
  
end