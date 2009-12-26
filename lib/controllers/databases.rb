module Databases
  
  # ---------------------------------------------------------------------------  
  get "/db/:page" do
    page       = params[:page].to_i || 1
    path_ids   = session[:path_ids]
    path_names = session[:path_names]
          
    @cltns     = options.connection.paginate_db( path_names, page, 10 )
    @title     = title_for( path_names )    
    @back_url  = "/explore/back"
    
    erb :db_list
  end  
  
end