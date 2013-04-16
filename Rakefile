require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose   = true
  t.ruby_opts = "-I./spec"
end

task :default => 'spec'
task 'gem:release' => 'spec'

# BOZO !!
# def ensure_in_path( *args )
#   args.each do |path|
#     path = File.expand_path(path)
#     $:.unshift(path) if test(?d, path) and not $:.include?(path)
#   end
# end
# 
# ensure_in_path 'lib'