# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongo3"

Gem::Specification.new do |s|
  s.name                      = 'mongo3'
  s.version                   = Mongo3::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = ["Fernand Galiana"]
  s.email                     = ["fernand.galiana@gmail.com"]
  s.homepage                  = 'http://www.mongo3.com'
  s.summary                   = 'Rule your mongoDB clusters'
  s.description               = 'Console to administer MongoDB'
  s.rubyforge_project         = "mongo3"
  s.files                     = `git ls-files`.split("\n")
  s.test_files                = `git ls-files -- {specs}/*`.split("\n")
  s.executables               = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths             = ["lib"]
  s.required_ruby_version     = ">= 1.9.2"   
  s.required_rubygems_version = ">= 1.3.7"  
  s.add_runtime_dependency      'mongo'                 , '>= 1.5.0'
  s.add_runtime_dependency      'bson'                  , '>= 1.6.0'
  s.add_runtime_dependency      'bson_ext'              , '>= 1.6.0'
  s.add_runtime_dependency      'agnostic-will_paginate', '>= 3.0.0'
  s.add_runtime_dependency      'memcache-client'       , '>= 1.5.0'
  s.add_runtime_dependency      'mongo_rack'            , '>= 0.0.1'
  s.add_runtime_dependency      'main'                  , '>= 4.2.0'
  s.add_runtime_dependency      'json'                  , '>= 1.2.0'
  s.add_runtime_dependency      'sinatra'               , '>= 1.3.0'
end
