module Mongo3
  class Connection
    
    def initialize( config_file )
      @config_file = config_file
    end
        
    # Connects to mongo given an environment
    # BOZO !! Auth... 
    # TODO - Need to close out connection via block
    def connect_for( env, &block )
      info = landscape[env]
      puts ">>> Connecting for #{env} -- #{info[:host]}-#{info[:port]}"
      con = Mongo::Connection.new( info[:host], info[:port] )
      yield con
      con.close()
    end
    
    def show( path, crumbs )
      path_tokens  = path.split( "|" )
      crumb_tokens = crumbs.split( "|" )
      info         = OrderedHash.new
      env          = path_tokens[1]
      
      if path_tokens.size == 2
        connect_for( env ) do |con|
          info[:name]        = env
          info[:host]        = con.host
          info[:port]        = con.port
          info[:databases]   = OrderedHash.new
          con.database_info.sort { |a,b| b[1] <=> a[1] }.each { |e| info[:databases][e[0]] = to_mb( e[1] ) }
          info[:server] = con.server_info
        end
      elsif path_tokens.size == 3
        db_name = crumb_tokens.pop
        connect_for( env ) do |con|
          db = con.db( db_name )
          info[:size] = to_mb( con.database_info[db_name] )
          info[:node] = db.nodes
          info[:collections] = db.collection_names.size
          info[:error]       = db.error
          info[:last_status] = db.last_status
        end
      elsif path_tokens.size == 4
        cltn_name = crumb_tokens.pop
        db_name   = crumb_tokens.pop
        connect_for( env ) do |con|
          db = con.db( db_name )
          cltn = db[cltn_name]
          info[:size] = cltn.count
          
          indexes = db.index_information( cltn_name )          
          info[:indexes] = format_indexes( db.index_information( cltn_name ) ) if indexes and !indexes.empty?
        end
      end
      
      info
    end
        
    def format_indexes( indexes )
      formatted = {}
      indexes.each_pair do |key, values|
        buff = []
        values.each do |pair|
          buff << "#{pair.first} [#{pair.last}]"
        end
        formatted[key] = buff
      end  
      formatted    
    end
    
    # Fetch the environment landscape from the config file
    def landscape
      config
    end

    # db request occurs within dist 2
    def db_request?( path )
      path.size == 2
    end
    
    # cltn request occurs within dist 3
    def cltn_request?( path )
      path.size == 3
    end

    # Build environment tree
    def build_tree
      root = Node.new( "home", "home", :path => 'home', :crumbs => 'home' )
      
      # iterate thru envs
      id = 1
      config.each_pair do |env, info|
        node = Node.new( env, env, :dyna => true )
        root << node
        id += 1
      end
      root
    end
    
    # Build an appropriate subtree based on requested item
    def build_sub_tree( path, crumbs )
      path_tokens  = path.split( "|" )
      crumb_tokens = crumbs.split( "|" )
      parent_id    = path_tokens.last
      db_name      = crumb_tokens.last
      
      if db_request?( path_tokens )
        sub_tree = build_db_tree( parent_id, db_name )
      else
        env = crumb_tokens[1]
        sub_tree = build_cltn_tree( parent_id, env, db_name )
      end
      sub_tree.to_adjacencies
    end
    
    
    # Connects to host and spews out all available dbs
    # BOZO !! Need to deal with Auth?
    def build_db_tree( parent_id, env )
      sub_root = nil
      connect_for( env ) do |con|      
        root = Node.new( "home", "home" )
        sub_root = Node.new( parent_id, env )
      
        root << sub_root
      
        count = 0
        data  = { :dyna => true }
        # excludes = %w[admin local]
        con.database_names.each do |db_name|
          # next if excludes.include?( db_name )
          db    = con.db( db_name, :strict => true )
          cltns = db.collection_names.size  
          node  = Node.new( "#{env}_#{count}", "#{db_name}(#{cltns})", data.clone )
          sub_root << node
          count += 1
        end
      end
      sub_root
    end
    
    # Show collections
    def build_cltn_tree( parent_id, env, db_name ) 
      sub_root = nil
      connect_for( env ) do |con|
        db        = con.db( db_name )      
        root      = Node.new( "home", "home" )
        env_node  = Node.new( env, env )
        sub_root  = Node.new( parent_id, db_name )
        root     << env_node
        env_node << sub_root
      
        count = 0
        # excludes = %w[system.indexes]
        data = { :dyna => false }
        db.collection_names.each do |cltn_name|
          # next if excludes.include?( cltn_name )
          size = db[cltn_name].count
          node = Node.new( "#{db_name}_#{count}", "#{cltn_name}(#{size})", data.clone )
          sub_root << node
          count += 1
        end
      end
      sub_root
    end
    
    # =========================================================================
    private
   
      # Convert size to mb
      def to_mb( val )
        return val if val < 1_000_000
        "#{format_number(val/1_000_000)}Mb"
      end
   
      # Add thousand markers
      def format_number( numb )
        numb.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
      end
        
      # Initialize the mongo installation landscape
      def config
        unless @config
          @config = YAML.load_file( @config_file )
        end
        @config
      end
            
  end
end