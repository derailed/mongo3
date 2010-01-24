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
      # BOZO !! Shit is dupped in connection. Fix it !!
      def connect_for( path, &block )
        zone = zone_for_path( path )        
        info = config[zone]
        raise "Unable to find zone info in config file for zone `#{zone}" unless info
        raise "Check your config. Unable to find `host information" unless info['host']
        raise "Check your config. Unable to find `port information" unless info['port']

        con = nil        
        begin
          con = Mongo::Connection.new( info['host'], info['port'], { :slave_ok => true } )
        
          if info['user'] and info['password']
            con.db( 'admin' ).authenticate( info['user'], info['password'] )
          end
        rescue => boom
          raise "MongoDB connection failed for `#{info['host']}:#{info['post']}"
        end        
          
        yield con        
        con.close()
      end
    
      # find zone matching the host and port combination
      # BOZO !! Dupped in connection. Fix it !!
      def zone_for( host, port )
        config.each_pair do |zone, info|
          return zone if info['host'] == host and info['port'] == port.to_i
        end
        nil
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