require 'json'

module Collections
  
  # --------------------------------------------------------------------------- 
  # Paginate on a collection
  get "/cltn/:page" do
    @back_url  = "/explore/back"
    @page      = params[:page].to_i || 1
    @title     = title_for( session[:path_names] )
    
    load_cltn( params[:page].to_i )
    erb :cltn_list
  end  
  
  # ---------------------------------------------------------------------------
  post "/cltn_refresh/:page" do
    selected_cols = params[:cols].keys.sort    
    session[:selected_cols] = selected_cols

    load_cltn( params[:page].to_i )
        
    erb :cltn_update_js, :layout => false
  end
  
  # ---------------------------------------------------------------------------
  # BOZO !! Validation....
  post "/cltn_search" do
    json = params[:search].gsub( /'/, "\"" )    
    if json.empty?
      @query = {}
      @sort  = {}
    else
      tokens = json.split( "|" )      
      @query = JSON.parse( tokens.shift )
      @sort  = tokens.empty? ? [] : JSON.parse( tokens.first )    
    end
    session[:query_params] = [@query, @sort]
    
    load_cltn
    erb :cltn_update_js, :layout => false
  end

  # ===========================================================================
  helpers do    
    def load_cltn( page=1 )
      query_params   = session[:query_params] || [{},[]]
      @query         = [query_params.first.to_json, query_params.last.to_json].join(",")
      @page          = page
      path_names     = session[:path_names]
      path_ids       = session[:path_ids]
      
      @cltn          = options.connection.paginate_cltn( path_names, query_params, @page, 15 )
      @cols          = @cltn.first.keys.sort
      @selected_cols = session[:selected_cols] || @cols[0...5]
    end
  end
end