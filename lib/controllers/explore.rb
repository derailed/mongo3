module Explore
  
  # -----------------------------------------------------------------------------
  get '/explore' do
    reset_crumbs!
    @root = options.connection.build_tree
    erb :explore
  end

  # -----------------------------------------------------------------------------
  get '/explore/show/:path/:crumbs' do
    path   = params[:path]
    crumbs = params[:crumbs]
    
    @info = options.connection.show( path, crumbs )
    
    partial :info
  end
  
  # -----------------------------------------------------------------------------
  get '/explore/more_data/:path/:crumbs/*' do
    path     = params[:path]
    crumbs   = params[:crumbs]
    
    crumbs_from_path( path, crumbs )    
    
    @sub_tree = options.connection.build_sub_tree( path, crumbs )
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