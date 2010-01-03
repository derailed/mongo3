module Mongo3
  class Zone

    attr_reader :config
        
    def initialize( config_file )
      @config_file = config_file
    end
    
    # =========================================================================
    protected
    
      def zone_for_path( path )
        path.split( "|" )[1]
      end
      
      # Connects to mongo given an zone
      def connect_for( path, &block )
        zone = zone_for_path( path )    
        info = config[zone]
        # puts ">>> Connecting for #{zone} -- #{info['host']}-#{info['port']}"
        con = Mongo::Connection.new( info['host'], info['port'], { :slave_ok => true } )
        
        if info['user'] and info['password']
          con.db( 'admin' ).authenticate( info['user'], info['password'] )
        end
        yield con      
        con.close()
      end
    
      # find zone matching the host and port combination
      def zone_for( host, port )
        config.each_pair do |zone, info|
          return zone if info['host'] == host and info['port'] == port.to_i
        end
        nil
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