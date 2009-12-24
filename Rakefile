# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'mongo3'

task :default => 'spec:run'

PROJ.name        = 'mongo3'
PROJ.authors     = 'Fernand Galiana'
PROJ.email       = 'fernand.galiana@gmail.com'
PROJ.url         = 'http://www.mongo3.com'
PROJ.version     = Mongo3::VERSION
PROJ.ruby_opts   = %w[-W0]
PROJ.readme      = 'README.rdoc'
PROJ.rcov.opts   = ["--sort", "coverage", "-T"]
PROJ.ignore_file = "*.log"
PROJ.spec.opts   << '--color'
PROJ.rdoc.include = %w[.rb]
