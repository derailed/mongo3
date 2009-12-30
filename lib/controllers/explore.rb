module Explore
  
  # -----------------------------------------------------------------------------  
  get "/explore/database/:db_id/:db_name/drop" do
    path_ids   = session[:path_ids]
    path_names = session[:path_names]
    @node_id   = params[:db_id]
    db_name    = params[:db_name].gsub( /\(\d+\)/, '' )
    
    options.connection.drop_database( session[:path_names], db_name )
    
    flash_it!( :info, "Database `#{db_name} was dropped successfully!" )
             
    erb :'explore/update.js', :layout => false
  end

  # -----------------------------------------------------------------------------
  get '/explore' do
    root   = options.connection.build_tree
    @root  = root.to_adjacencies
    @nodes = root.children
    
    reset_crumbs!
    reset_paths!

# Mongo3::Node.dump_adj( @root )    
    erb :'explore/explore'
  end

  # -----------------------------------------------------------------------------
  get '/explore/back' do  
    session[:selected_cols] = nil
    session[:query_params]  = nil
 
    back_paths! 
    
    reset_crumbs!
    path_names = session[:path_names]
    path_ids   = session[:path_ids]
    @node_id   = path_ids.split('|').last    
    
    crumbs_from_path( path_ids, path_names )
    
    @root  = options.connection.build_partial_tree( path_names )
    @nodes = @root.find( @node_id ).children
         
    erb :'explore/explore'
  end
  
  # -----------------------------------------------------------------------------
  get '/explore/show/:path_ids/:path_names' do
    path_ids   = params[:path_ids]
    path_names = params[:path_names]

    update_paths!( path_ids, path_names )   
        
    @info = options.connection.show( path_names )    
    partial :'explore/info'
  end
  
  # -----------------------------------------------------------------------------
  get '/explore/more_data/:path_ids/:path_names/*' do
    path_ids   = params[:path_ids]
    parent_id  = path_ids.split("|").last
    path_names = params[:path_names]

    update_paths!( path_ids, path_names )   
    
    crumbs_from_path( path_ids, path_names )    
    
    root = options.connection.build_sub_tree( parent_id, path_names )    
    @sub_tree = root.to_adjacencies
    @node_id  = @sub_tree.first[:id]
    @nodes    = root.children
# Mongo3::Node.dump_adj( @sub_tree )    
    erb :'explore/more_data_js', :layout => false
  end

  # -----------------------------------------------------------------------------
  get '/explore/update_crumb/:path_ids/:path_names' do
    path_ids   = params[:path_ids]
    path_names = params[:path_names]
    
    crumbs_from_path( path_ids, path_names )
    update_paths!( path_ids, path_names )
    
    root   = options.connection.build_partial_tree( path_names )
    node_id  = path_ids.split( "|" ).last
    @nodes = root.find( node_id ).children
    
    erb :'explore/update_crumb_js', :layout => false
  end
  
  # -----------------------------------------------------------------------------  
  get '/explore/center/:path_ids/:path_names' do
    path_ids   = params[:path_ids]
    path_names = params[:path_names]
    @node_id   = path_ids.split( "|" ).last 
    
    update_paths!( path_ids, path_names )
    pop_crumb!( path_names, path_ids )
    
    root   = options.connection.build_partial_tree( path_names )
    @nodes = root.find( @node_id ).children
    
    erb :'explore/center_js', :layout => false
  end
      
end