require 'yaml'

# BOZO !! Time to refact no?
# TODO !! Arg check and errors
# TODO !! Add logging
module Mongo3
  class Connection
    
    def initialize( config_file )
      @config_file = config_file
    end

    # drop a db using a db path    
    def drop_db( path_names )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]
      connect_for( zone ) do |con|
        db_name   = path_name_tokens.pop
        con.drop_database( db_name )
      end
    end

    def indexes_for( path_names )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]
      indexes          = {}
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]
        indexes   = cltn.index_information
      end
      indexes
    end

    def drop_index( path_names, index )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]        
        cltn.drop_index( index )
      end
    end
    
    def create_index( path_names, index, constraints )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]      
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]
        cltn.create_index( index, constraints ? constraints['unique'] == 1 : false )
      end      
    end

    def drop_cltn( path_names )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]      
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]
        cltn.drop
      end
    end

    def clear_cltn( path_names )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]      
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]
        cltn.remove( {} )
      end
    end
           
    def delete_row( path_names, id )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]      
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]
        res = cltn.remove( {:_id => Mongo::ObjectID.from_string(id) } )
      end
    end
         
    def show( path_names )
      path_name_tokens = path_names.split( "|" )
      info             = OrderedHash.new
      zone             = path_name_tokens[1]

      info[:links] = OrderedHash.new      
      info[:title] = path_name_tokens.last
            
      # If detect slave only show reg info
      slave = slave_zone?( path_name_tokens )
      if path_name_tokens.size == 2 or slave
        connect_for( zone ) do |con|
          info[:links][:users]  = "/users/1" unless slave
          info[:name]           = zone
          info[:host]           = con.host
          info[:users]          = con.db('admin')[Mongo::DB::SYSTEM_USER_COLLECTION].count rescue 0
          info[:port]           = con.port
          info[:databases]      = OrderedHash.new
          con.database_info.sort { |a,b| b[1] <=> a[1] }.each { |e| info[:databases][e[0]] = to_mb( e[1] ) }
          info[:server]         = con.server_info
        end
      # BOZO !! Need to figure out links strategy!
      elsif path_name_tokens.size == 3
        db_name = path_name_tokens.pop
        connect_for( zone ) do |con|          
          db = con.db( db_name )
          info[:links][:manage] = "/databases/1"
          info[:size]           = to_mb( con.database_info[db_name] )
          info[:node]           = db.nodes
          info[:collections]    = collection_names( db ).size
          info[:error]          = db.error
          info[:last_status]    = db.last_status
        end
      elsif path_name_tokens.size == 4        
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        connect_for( zone ) do |con|
          db      = con.db( db_name )
          cltn    = db[cltn_name]
          indexes = db.index_information( cltn_name )
                    
          info[:links][:manage] = "/collections/1"
          info[:size]           = cltn.count
          info[:indexes]        = format_indexes( indexes ) if indexes and !indexes.empty?
        end
      end      
      info
    end

    def paginate_db( path_names, page=1, per_page=10 )
      path_name_tokens = path_names.split( "|" )      
      zone              = path_name_tokens[1]
      list             = nil
      connect_for( zone ) do |con|
        db_name = path_name_tokens.pop
        db      = con.db( db_name )
        cltn    = collection_names(db).sort
        
        list = WillPaginate::Collection.create( page, per_page, cltn.size ) do |pager|
          offset = (page-1)*per_page
          names = cltn[offset..(offset+per_page)]
          cltns = []
          names.each do |name|
            list = db[name]
            row  = OrderedHash.new
            row[:name]  = name
            row[:count] = list.count
            cltns << row
          end          
          pager.replace( cltns ) 
        end        
      end
      list
    end
        
    def paginate_cltn( path_names, query_params=[{},[]], page=1, per_page=10 )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]
      list             = nil
      connect_for( zone ) do |con|
        cltn_name = path_name_tokens.pop
        db_name   = path_name_tokens.pop
        db        = con.db( db_name )
        cltn      = db[cltn_name]          
        count     = cltn.find( query_params.first ).count
        
        list = WillPaginate::Collection.create( page, per_page, count ) do |pager|
          offset = (page-1)*per_page
          sort   = query_params.last.empty? ? [ ['_id', Mongo::DESCENDING] ] : query_params.last
          query  = query_params.first
          
          # Scan for regexes...
          query.each_pair do |k,v|
            if v.is_a?( String ) and v.index( /^\// )
              query[k] = Regexp.new( v.gsub( "/", '' ) )
            end
          end
          results = cltn.find( query, 
            :sort  => sort,
            :skip  => offset, 
            :limit => per_page ).to_a          
          pager.replace( results )
        end        
      end
      list
    end
            
    # Fetch the cluster landscape from the config file
    def landscape
      config
    end

    # Build zone tree
    def build_tree
      root = Node.make_node( "home" )
      
      # iterate thru zones
      adjacencies = {}
      config.each_pair do |zone, info|
        node = Node.new( zone, zone, :dyna => true )
        root << node
        adjs = adjacencies[zone]
        if adjs
          node.mark_master!
          adjs.each { |n| node << n }
        end
        masters = slave?( zone )
        next if masters.empty?

        node.mark_slave!     
        masters.each do |master|
          host, port = master.split( ":" )
          master_zone = zone_for( host, port )
          next unless master_zone
          master_node = root.find( master_zone )
          if master_node
            master_node.mark_master!
            master_node << node
          else
            adjacencies[master_zone] = [] unless adjacencies[master_zone]
            adjacencies[master_zone] << node
          end
        end
      end
      root
    end
    
    def slave?( zone )
      masters = []
      connect_for( zone ) do |con|
        local = con.db( "local", :strict => true )
        return masters unless local
        begin
          sources = local['sources']
          srcs    = sources.find( {}, :fields => [:host] )
          srcs.each{ |src| masters << src['host'] }          
        rescue => boom
          ;
        end
      end
      masters
    end
    
    # Build zone tree
    def build_partial_tree( path_names )
      path_name_tokens = path_names.split( "|" )      
      bm_zone          = path_name_tokens[1]
      bm_cltn          = path_name_tokens.pop if path_name_tokens.size == 4
      bm_db            = path_name_tokens.pop if path_name_tokens.size == 3
      
      root = Node.make_node( "home" )
      
      # iterate thru zones
      adjacencies = {}      
      config.each_pair do |zone, info|
        node = Node.new( zone, zone, :dyna => true )
        root << node
        
        adjs = adjacencies[zone]
        if adjs
          node.mark_master!
          adjs.each { |n| node << n }
        end
        masters = slave?( zone )
        
        unless masters.empty?
          node.mark_slave!     
          masters.each do |master|
            host, port  = master.split( ":" )
            master_zone = zone_for( host, port )
            next unless master_zone
            master_node = root.find( master_zone )
            if master_node
              master_node.mark_master!
              master_node << node
            else
              adjacencies[master_zone] = [] unless adjacencies[master_zone]
              adjacencies[master_zone] << node
            end
          end
        end
                
        next unless node.name == bm_zone
                
        connect_for( zone ) do |con|      
          count = 0
          data  = { :dyna => true }
          database_names( con ).each do |db_name|
            db      = con.db( db_name, :strict => true )
            cltns   = collection_names( db )  
            db_node = Node.new( "#{zone}_#{count}", "#{db_name}(#{cltns.size})", data.clone )
            node << db_node
            count += 1
            if bm_db and db_node.name =~ /^#{bm_db}/
              cltn_count = 0
              data = { :dyna => false }
              cltns.each do |cltn_name|
                size = db[cltn_name].count
                cltn_node = Node.new( "#{db_name}_#{cltn_count}", "#{cltn_name}(#{size})", data.clone )
                db_node << cltn_node
                cltn_count += 1
              end              
            end
          end
        end
      end
      root
    end
    
    # Build an appropriate subtree based on requested item
    def build_sub_tree( parent_id, path_names )
      path_name_tokens = path_names.split( "|" )
      zone              = path_name_tokens[1]      
            
      if db_request?( path_name_tokens )        
        sub_tree = build_db_tree( parent_id, zone )
      else
        db_name  = path_name_tokens.last        
        sub_tree = build_cltn_tree( parent_id, zone, db_name )
      end
      sub_tree
    end
        
    # Connects to host and spews out all available dbs
    # BOZO !! Need to deal with Auth?
    def build_db_tree( parent_id, zone )    
      sub_root = nil
      connect_for( zone ) do |con|
        root     = Node.make_node( "home" )
        sub_root = Node.new( parent_id, zone )
      
        root << sub_root
      
        count = 0
        data  = { :dyna => true }
        database_names( con ).each do |db_name|
          db    = con.db( db_name, :strict => true )
          cltns = collection_names( db ).size  
          node  = Node.new( "#{zone}_#{count}", "#{db_name}(#{cltns})", data.clone )
          sub_root << node
          count += 1
        end
      end
      sub_root
    end
    
    # Show collections
    def build_cltn_tree( parent_id, zone, db_name ) 
      sub_root = nil
      connect_for( zone ) do |con|
        db        = con.db( db_name )      
        root      = Node.make_node( "home" )
        zone_node  = Node.make_node( zone )
        sub_root  = Node.new( parent_id, db_name )
        root     << zone_node
        zone_node << sub_root
      
        count = 0
        data = { :dyna => false }
        collection_names( db ).each do |cltn_name|
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
      
      def collection_names( db )
        excludes = %w[system.indexes]
        db.collection_names - excludes 
      end
      
      # Filters out system dbs
      def database_names( con )
        excludes = %w[admin local slave]
        con.database_names - excludes
      end
      
      # Connects to mongo given an zone
      def connect_for( zone, &block )
        info = landscape[zone]
        raise "Unable to find zone info in config file for zone `#{zone}" unless info
        raise "Check your config. Unable to find `host information" unless info['host']
        raise "Check your config. Unable to find `port information" unless info['port']
        
        begin
          con = Mongo::Connection.new( info['host'], info['port'], { :slave_ok => true } )
        
          if info['user'] and info['password']
            con.db( 'admin' ).authenticate( info['user'], info['password'] )
          end
          yield con        
          con.close()
        rescue => boom
          # puts boom
          # puts boom.backtrace.each {|l| puts l }          
          raise "MongoDB connection failed for `#{info['host'].inspect}:#{info['port'].inspect}"
        end
      end

      # db request occurs within dist 2
      def db_request?( path )
        path.size == 2
      end
    
      # cltn request occurs within dist 3
      def cltn_request?( path )
        path.size == 3
      end

      # Break down indexes in index + asc/desc   
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
   
      # Convert size to mb
      def to_mb( val )
        return 0 unless val
        return val if val < 1_000_000
        "#{format_number(val/1_000_000)}Mb"
      end
   
      # Add thousand markers
      def format_number( numb )
        numb.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
      end
        
      # find zone matching the host and port combination
      def zone_for( host, port )
        config.each_pair do |zone, info|
          return zone if info['host'] == host and info['port'] == port.to_i
        end
        nil
      end

      # Check if this is a slave or a db path   
      def slave_zone?( tokens )
        return false unless tokens.size == 3
        return false unless config.keys.include?( tokens.last )
        true
      end
      
      # Initialize the mongo installation landscape
      def config
        unless @config
          begin
            @config = YAML.load_file( @config_file )
          rescue => boom
            @config = nil
            raise "Unable to grok yaml landscape file. #{boom}"
          end
        end
        @config
      end            
  end
end