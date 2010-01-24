require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Mongo3 do
 before( :all ) do
    @root = ::File.expand_path( ::File.join(::File.dirname(__FILE__), ".." ) )
  end

  it "is versioned" do
    Mongo3.version.should =~ /\d+\.\d+\.\d+/
  end

  it "generates a correct path relative to root" do
    Mongo3.path( "mongo3.rb" ).should == ::File.join(@root, "mongo3.rb" )
  end

  it "generates a correct path relative to lib" do
    Mongo3.libpath(%w[ mongo3 node.rb]).should == ::File.join( @root, "lib", "mongo3", "node.rb" )
  end

end
