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

  s.add_dependency 'mongo'                 , '>= 1.8.5'
  s.add_dependency 'bson'                  , '>= 1.8.5'
  s.add_dependency 'bson_ext'              , '>= 1.8.5'
  s.add_dependency 'will_paginate'         , '>= 3.0.4'
  s.add_dependency 'memcache-client'       , '>= 1.8.5'
  s.add_dependency 'mongo_rack'            , '>= 0.0.5'
  s.add_dependency 'main'                  , '>= 5.2.0'
  s.add_dependency 'json'                  , '>= 1.7.0'
  s.add_dependency 'sinatra'               , '>= 1.4.0'
  s.add_dependency 'map'                   , '>= 6.3.0'  
end