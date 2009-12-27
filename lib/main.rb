require 'rubygems'
require 'sinatra'
require 'forwardable'
require File.join( File.dirname(__FILE__), 'mongo3.rb' )
require 'mongo'
gem 'agnostic-will_paginate'
require 'will_paginate'

set :public, File.join( File.dirname(__FILE__), %w[public] )
set :views , File.join( File.dirname(__FILE__), %w[views] )

# -----------------------------------------------------------------------------
# Configuration
configure do
  Mongo3.load_all_libs_relative_to(__FILE__, 'helpers' )
  Mongo3.load_all_libs_relative_to(__FILE__, 'controllers' )
  
  use Rack::Session::Memcache, :namespace => 'mongo3'
  
  set :connection, Mongo3::Connection.new( File.join( ENV['HOME'], %w[.mongo3 landscape.yml] ) )
end

# -----------------------------------------------------------------------------
# Before filters
before do
  unless request.path =~ /\.[css gif png js]/
    @crumbs = session[:crumbs]
    unless @crumbs
      @crumbs = [ ['home', '/explore/center/home'] ]
      session[:crumbs] = @crumbs
    end
  end
end

# =============================================================================
# Helpers
helpers do
        
  # Convert size to mb
  def to_mb( val )
    return val if val < 1_000_000
    "#{val/1_000_000}Mb"
  end  
end
