require 'mongo'
require File.join( File.dirname(__FILE__), %w[zone.rb] )

module Mongo3
  # Administer users on a connection  
  class User < Mongo3::Zone
    
    # add a new user    
    def add( path, user_name, password )
      connect_for( path ) do |con|
        user_cltn = users( con )

        row = { :user => user_name }        
        user = user_cltn.find_one( row )
        raise "User #{user_name} already exists!" if user
        
        row[:pwd] = user_cltn.db.send( :hash_password, user_name, password )
        return user_cltn.save( row )
      end     
    end
    
    def clear!( path )
      connect_for( path ) do |con|
        res = users( con ).remove( {} )
      end            
    end
    
    def rename( zone, old_name, new_name )
      raise "NYI"
    end
    
    def delete( path, id )
      connect_for( path ) do |con|
        res = users( con ).remove( :_id => Mongo::ObjectID.from_string( id ) )
      end      
    end
        
    def list( path, page, per_page=10 )
      connect_for( path ) do |con|
        user_cltn = users( con )
        list = WillPaginate::Collection.create( page, per_page, user_cltn.size ) do |pager|
          offset = (page-1)*per_page
          results = user_cltn.find( {}, 
            :sort  => [['user', Mongo::ASCENDING]],
            :skip  => offset,
            :limit => per_page ).to_a          
          return pager.replace( results )
        end
      end
    end
    
    private    
      
      def users( con )
        admin = con.db('admin')
        admin[Mongo::DB::SYSTEM_USER_COLLECTION]        
      end
  end
end