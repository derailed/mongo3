require 'simplecov'

if ENV['COV']
  SimpleCov.start do
    add_filter "spec/"
  end
end

require 'mongo3'

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