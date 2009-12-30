require 'json'
require 'mongo/util/ordered_hash'

module Mongo3
  class Node
    attr_accessor :oid, :name, :children, :data, :parent
    
    def initialize( oid, name, data=nil )
      @oid      = oid
      @name     = name
      @children = []
      @data     = data || OrderedHash.new
      @parent   = nil
    end
    
    def self.make_node( name )
      Node.new( name, name, :path_ids => name, :path_names => name )
    end
    
    def mark_slave!
      data[:slave] = true
      data['$lineWidth'] = 3
      data['$color']     = "#434343"
      data['$dim']       = 15
    end
    
    def mark_master!
      data[:master]  = true
      data['$color'] = '#92b948'
      data['$dim']       = 15
      data['$lineWidth'] = 3      
    end
    
    def master?
      data.has_key?( :master )
    end
    
    def slave?
      data.has_key?( :slave )
    end
    
    # Add a child node
    def <<( new_one )
      new_one.parent = self
      @children << new_one
      update_paths( new_one )
    end

    def find( node_id )
      _find( self, node_id )
    end

    def _find( node, node_id )      
      return node if node.oid == node_id
      unless node.children.empty?
        node.children.each { |c| found = _find( c, node_id ); return found if found }
      end
      nil
    end
          
    # convert a tree node to a set of adjacencies
    def to_adjacencies
      cltn = []
      _to_adjacencies( self, cltn )
      cltn
    end
    
    def _to_adjacencies( node, cltn )
      node_level = { :id => node.oid, :name => node.name, :data => node.data, :adjacencies => [] } 
      cltn << node_level
      node.children.each do |child|
        node_level[:adjacencies] << child.oid
        _to_adjacencies( child, cltn )
        # cltn << { :id => child.oid, :name => child.name, :data => child.data, :adjacencies => [] } 
      end
      # cltn
    end
    
    # converts to json
    def to_json(*a)
      hash = OrderedHash.new
      hash[:id]       = oid
      hash[:name]     = self.name
      hash[:children] = self.children
      hash[:data]     = self.data 
      hash.to_json(*a)
    end

    # Debug...
        
    # Dump nodes to stdout
    def self.dump( node, level=0 )
      puts '  '*level + "%-#{20-level}s (%d) [%s] -- %s" % [node.oid, node.children.size, node.name, (node.data ? node.data.inspect : 'N/A' )]
      node.children.each { |c| dump( c, level+1 ) }
    end

    # Dump adjancencies to stdout
    def self.dump_adj( adjs, level = 0 )
      adjs.each do |adj|   
        puts '  '*level + "%-#{20-level}s (%d) [%s] -- %s" % [adj[:id], adj[:adjacencies].size, adj[:name], (adj[:data] ? adj[:data].inspect : 'N/A' )]
      end
    end

    # =========================================================================
    private
    
      def update_paths( node )
        node.data[:path_names] = node.send( :path, :name )
        node.data[:path_ids]   = node.send( :path, :oid )
        node.children.each do |child|
          child.send( :update_paths, child )
        end
      end  
          
      def path( accessor=:oid )
        path = []
        traverse( path, self, accessor )
        path.reverse.join( "|" )
      end
    
      def traverse( path, node, accessor )
        path << node.send( accessor ).to_s.gsub( /\(\d+\)/, "" )
        if node.parent
          traverse( path, node.parent, accessor )
        end
      end 
  end
end