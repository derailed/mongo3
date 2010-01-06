require 'rubygems'
require 'rack'
require 'rack/test'
require 'mongo'
gem 'agnostic-will_paginate'
require 'will_paginate/collection'

require File.expand_path( File.join( File.dirname(__FILE__), %w[.. lib mongo3] ) )

Spec::Runner.configure do |config|
end