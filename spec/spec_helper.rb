require 'mongo3'
require 'simplecov'

if ENV['COV']
  SimpleCov.start do
  end
end

# gem 'agnostic-will_paginate'
# require 'will_paginate/collection'
# 
# require File.expand_path( File.join( File.dirname(__FILE__), %w[.. lib mongo3] ) )

RSpec.configure do |config|
  begin
    Mongo::Connection.new( 'localhost', 12345 )
  rescue => boom
    puts "\n"*3
    puts "<OH SNAP!!>"
    puts ""
    puts "To run the tests you need to a local instance of mongodb on port 12345"
    puts ""
    puts "> mongod --dbpath /data/db/mongo3 --port 12345"
    puts "\n"*3
    raise "Bailing out"
  end  
end