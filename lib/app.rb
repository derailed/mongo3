require 'rubygems'
require 'sinatra'
require 'forwardable'
require File.join( File.dirname(__FILE__), 'mongo3.rb' )
require 'mongo'
gem 'agnostic-will_paginate'
require 'will_paginate'
require 'mongo_rack'

set :public, File.join( File.dirname(__FILE__), %w[public] )
set :views , File.join( File.dirname(__FILE__), %w[views] )

# -----------------------------------------------------------------------------
# Configurations

configure :production do
  set :logging, false  
end

configure do
  Mongo3.load_all_libs_relative_to(__FILE__, 'helpers' )
  Mongo3.load_all_libs_relative_to(__FILE__, 'controllers' )
 
  # Pick up command line args if any?  
  if defined? @@options and @@options
    if @@options[:protocol] == 'mongo'
      use Rack::Session::Mongo, 
        :server => "%s:%d/%s/%s" % [@@options[:host], @@options[:port], @@options[:db_name], @@options[:cltn_name]]
    else
      use Rack::Session::Memcache, 
        :memcache_server => "%s:%d" % [@@options[:host], @@options[:port]],
        :namespace       => @@options[:namespace]
    end
  else
    # Default is a mongo session store
    use Rack::Session::Mongo
  end
  set :config_file, File.join( ENV['HOME'], %w[.mongo3 landscape.yml] )
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
