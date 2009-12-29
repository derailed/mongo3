require 'json'

module Collections
  
# [ ['last_name', -1], ['name', 1] ]  
  # ---------------------------------------------------------------------------
  post "/collections/create_index/" do
    json   = params[:index].gsub( /'/, "\"" )
    tokens = json.split( "|" )
    
    begin
      raise "You need to enter an index description" if tokens.empty?
      index       = JSON.parse( tokens.shift )
      constraints = tokens.empty? ? nil : JSON.parse( tokens.first )
      
      options.connection.create_index( session[:path_names], index, constraints )
      flash_it!( :info, "Index was created successfully!" )
    rescue => boom
      flash_it!( :error, boom )
      return erb(:'shared/flash.js', :layout => false)
    end

    @indexes = options.connection.indexes_for( session[:path_names] )
        
    erb :'collections/update_indexes.js', :layout => false    
  end
  
  # ---------------------------------------------------------------------------  
  post "/collections/drop_index/" do
    options.connection.drop_index( session[:path_names], params[:id] )
    flash_it!( :info, "Index was dropped successfully!" )
    erb :'shared/flash.js', :layout => false
  end

  # --------------------------------------------------------------------------- 
  # Paginate on a collection
  get "/collections/:page" do    
    @back_url  = "/explore/back"
    @page      = params[:page].to_i || 1

    @indexes = options.connection.indexes_for( session[:path_names] )
    
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
        session[:query_params] = [@query, @sort]
        load_cltn        
      rescue => boom
        flash_it!( :error, boom )
        return erb(:'shared/flash.js', :layout => false)
      end
    end
    
    erb :'collections/update.js', :layout => false
  end

  post '/collections/delete/' do
    path_names = session[:path_names]
    options.connection.delete_row( path_names, params[:id] )
    load_cltn
    
    flash_it!( :info, "Row was deleted successfully!" )
    
    erb :'collections/update.js', :layout => false    
  end

  get '/collections/clear/' do
    path_names = session[:path_names]
    options.connection.clear_cltn( path_names )    
    flash_it!( :info, "Collection `#{path_names.split('|').last} was cleared successfully!" )
    erb :'collections/all_done.js', :layout => false    
  end

  get '/collections/drop/' do
    path_names = session[:path_names]
    options.connection.drop_cltn( path_names )    
    flash_it!( :info, "Collection `#{path_names.split('|').last} was dropped successfully!" )        
    erb :'collections/all_done.js', :layout => false    
  end
  
  # ===========================================================================
  helpers do    
    def load_cltn( page=1 )
      query_params = session[:query_params] || [{},[]]
      if ( !query_params.first or query_params.first.empty?) and ( !query_params.last or query_params.last.empty? )
        @query = nil
      else  
        @query = [query_params.first.to_json, query_params.last.to_json].join( " | " )
        @query.gsub!( /\"/, "'" )
      end
      @page          = page
      path_names     = session[:path_names]
      
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