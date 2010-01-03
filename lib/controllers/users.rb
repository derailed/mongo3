module Users
  # --------------------------------------------------------------------------- 
  # Paginate users
  get "/users/:page" do    
    @back_url  = "/explore/back"
    @page      = params[:page].to_i || 1

    user_mgmt = Mongo3::User.new( options.config_file )    
    @users    = user_mgmt.list( session[:path_names], @page, 10 )
        
    erb :'users/list'
  end
  
  # ---------------------------------------------------------------------------  
  post "/users/delete/" do
    id        = params[:id]
    user_mgmt = Mongo3::User.new( options.config_file ) 

    user_mgmt.delete( session[:path_names], id )    
    flash_it!( :info, "User was dropped successfully!" )            
    @users = user_mgmt.list( session[:path_names], 1, 10 )
  
    erb :'users/results.js', :layout => false
  end

  # ---------------------------------------------------------------------------  
  post "/users/add/" do
    user_name = params[:user]
    passwd    = params[:passwd]
    user_mgmt = Mongo3::User.new( options.config_file ) 

    begin
      user_mgmt.add( session[:path_names], user_name, passwd )
      flash_it!( :info, "User #{user_name} was added successfully!" )      
    rescue => boom
      flash_it!( :error, boom )
    ensure
      @users = user_mgmt.list( session[:path_names], 1, 10 )
    end
  
    erb :'users/results.js', :layout => false
  end
  
end