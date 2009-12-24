require 'json'

module Mongo3
  class Node
    attr_accessor :oid, :name, :children, :data, :parent
    
    def initialize( oid, name, data={} )
      @oid      = oid
      @name     = name
      @children = []
      @data     = data || {}
      @parent   = nil
    end
    
    # Add a child node
    def <<( new_one )
      new_one.parent = self
      @children << new_one
      update_paths( new_one )
    end

    def update_paths( node )
      node.data[:crumbs] = node.path( :name )
      node.data[:path]   = node.path
      node.children.each do |child|
        child.update_paths( child )
      end
    end  
      
    # convert a tree node to a set of adjacencies
    def to_adjacencies
      root_level = { :id => self.oid, :name => self.name, :data => self.data, :adjacencies => [] } 
      cltn = [ root_level ]
      self.children.each do |child|
        root_level[:adjacencies] << child.oid
        cltn << { :id => child.oid, :name => child.name, :data => child.data, :adjacencies => [] } 
      end
      cltn
    end
    
    def path( accessor=:oid )
      path = []
      traverse( path, self, accessor )
      path.reverse.join( "|" )
    end
    
    def traverse( path, node, accessor )
      path << node.send( accessor ).gsub( /\(\d+\)/, "" )
      if node.parent
        traverse( path, node.parent, accessor )
      end
    end
    
    # converts to json
    def to_json(*a)
      {
        'id'         => oid,
        'name'       => self.name,
        'children'   => self.children,
        'data'       => self.data
      }.to_json(*a)
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
    
  end
end