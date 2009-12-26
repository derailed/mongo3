module Explore
  
  # -----------------------------------------------------------------------------
  get '/explore' do
    reset_crumbs!
    @root = options.connection.build_tree
# Mongo3::Node.dump( @root )
    erb :explore
  end

  # -----------------------------------------------------------------------------
  get '/explore/back' do  
    session[:selected_cols] = nil
    session[:query_params]  = nil
 
    back_paths!
    path_ids   = session[:path_ids]
    path_names = session[:path_names]
    
    reset_crumbs!
    crumbs_from_path( path_ids, path_names )
    
    @root = options.connection.build_partial_tree( path_ids, path_names )
# Mongo3::Node.dump( @root )
    
    # need to adjust crumbs in case something got blown...
    @center = path_ids.split( "|" ).last
     
    erb :explore
  end
  
  # -----------------------------------------------------------------------------
  get '/explore/show/:path_ids/:path_names' do
    path_ids   = params[:path_ids]
    path_names = params[:path_names]
    
    @info = options.connection.show( path_names )
        
    session[:path_ids]   = path_ids
    session[:path_names] = path_names
    
    partial :info
  end
  
  # -----------------------------------------------------------------------------
  get '/explore/more_data/:path_ids/:path_names/*' do
    path_ids   = params[:path_ids]
    path_names = params[:path_names]

    session[:path_ids]   = path_ids
    session[:path_names] = path_names
    
    crumbs_from_path( path_ids, path_names )    
    
    @sub_tree = options.connection.build_sub_tree( path_ids, path_names )
# Mongo3::Node.dump_adj( @sub_tree )
    @node_id  = @sub_tree.first[:id]
    
    erb :more_data_js, :layout => false
  end

  # -----------------------------------------------------------------------------
  get '/explore/update_crumb/:path/:crumbs' do
    crumbs_from_path( params[:path], params[:crumbs] )
    erb :update_crumb_js, :layout => false
  end
  
  # -----------------------------------------------------------------------------  
  get '/explore/center/:node_id' do
    @node_id = params[:node_id]  
      
    pop_crumb!( @node_id )
    
    erb :center_js, :layout => false
  end
      
end