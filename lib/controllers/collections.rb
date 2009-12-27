require 'json'

module Collections
  
  # --------------------------------------------------------------------------- 
  # Paginate on a collection
  get "/collections/:page" do
    @back_url  = "/explore/back"
    @page      = params[:page].to_i || 1
    @title     = title_for( session[:path_names] )
    
    load_cltn( params[:page].to_i )
    erb :'collections/list'
  end  
  
  # ---------------------------------------------------------------------------
  post "/collections/refresh/:page/" do
    selected_cols = params[:cols].keys.sort    
    session[:selected_cols] = selected_cols

    load_cltn( params[:page].to_i )
        
    erb :'collections/update.js', :layout => false
  end
  
  # ---------------------------------------------------------------------------
  # BOZO !! Validation....
  post "/collections/search/" do
    json = params[:search].gsub( /'/, "\"" )
    if json.empty?
      @query = {}
      @sort  = {}
    else
      tokens = json.split( "|" )
      begin
        @query = JSON.parse( tokens.shift )
        @sort  = tokens.empty? ? [] : JSON.parse( tokens.first )
      rescue => boom        
        flash_it!( :error, boom )
        return erb(:'shared/flash.js', :layout => false)
      end
    end
    session[:query_params] = [@query, @sort]
    
    load_cltn
    erb :'collections/update.js', :layout => false
  end

  post '/collections/delete/' do
    path_names = session[:path_names]
    options.connection.delete_row( path_names, params[:id] )
    load_cltn
    erb :'collections/update.js', :layout => false    
  end

  get '/collections/clear/' do
    path_names = session[:path_names]
    options.connection.clear_cltn( path_names )
    load_cltn
    
    flash_it!( :info, "Collection #{path_names.split('|').last} was cleared successfully!" )
    erb :'collections/results.js', :layout => false    
  end

  get '/collections/drop/' do
    path_names = session[:path_names]
    options.connection.drop_cltn( path_names )
    load_cltn
    
    flash_it!( :info, "Collection #{path_names.split('|').last} was dropped successfully!" )        
    erb :'collections/results.js', :layout => false    
  end
  
  # ===========================================================================
  helpers do    
    def load_cltn( page=1 )
      query_params   = session[:query_params] || [{},[]]
      
      if query_params.first.empty? and query_params.last.empty?
        @query = nil
      else  
        @query = [query_params.first.to_json, query_params.last.to_json].join( " | " )
        @query.gsub!( /\"/, "'" )
      end
puts "QUERY #{@query.inspect}"      
      @page          = page
      path_names     = session[:path_names]
      path_ids       = session[:path_ids]
      
      @cltn          = options.connection.paginate_cltn( path_names, query_params, @page, 15 )
      @cols          = []
      @selected_cols = []      
      unless @cltn.empty?
        @cols          = @cltn.first.keys.sort
        @selected_cols = session[:selected_cols] || @cols[0...5]
      end
    end
  end
end