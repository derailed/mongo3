require 'bundler'
Bundler::GemHelper.install_tasks

task :default => 'spec'
task 'gem:release' => 'spec'

def ensure_in_path( *args )
  args.each do |path|
    path = File.expand_path(path)
    $:.unshift(path) if test(?d, path) and not $:.include?(path)
  end
end

ensure_in_path 'lib'