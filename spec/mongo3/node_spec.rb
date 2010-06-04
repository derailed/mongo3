require File.expand_path( File.join( File.dirname(__FILE__), %w[.. spec_helper] ) )
require 'ostruct'

describe Mongo3::Node do
  
  before( :all ) do
    @root = Mongo3::Node.new( 0, "root", :blee => 'duh', :fred => 10 )
    id = 100
    
    @envs = []
    2.times do |i|
      node = Mongo3::Node.new( id, "env_#{i}" )
      @envs << node
      @root << node
      id += 1
    end
    
    @dbs   = []
    @cltns = []
    4.times do |i|
      db = Mongo3::Node.new( id, "db_#{i}" )
      @dbs << db
      4.times do |j|
        cltn = Mongo3::Node.new( id, "cltn_#{j}" )
        @cltns << cltn
        db << cltn
        id += 1
      end
      if i % 2 == 0
        @root.children.first << db
      else
        @root.children.last << db
      end
      id += 1
    end
  end
  
  it "should make a new node correctly" do
    node = Mongo3::Node.make_node( "blee" )
    node.name.should              == "blee"
    node.oid.should               == "blee"
    node.data[:path_ids].should   == "blee"
    node.data[:path_names].should == "blee"
  end
  
  it "should create a node correctly" do
    @root.oid.should         == 0
    @root.name.should        == "root"
    @root.children.should    have(2).items    
    @root.data.should_not    be_nil
    @root.data[:blee].should == 'duh'
    @root.data[:fred].should == 10
  end
  
  it "should add children correctly" do
    @root.children.should            have(2).items
    @root.children.first.name.should == "env_0"
    @root.children.last.name.should  == "env_1"
  end
  
  it "should set the parent correctly" do
    @root.parent.should be_nil
    @envs.each do |env|
      env.parent.should == @root
    end
    
    @dbs.each do |db|
      db.parent.name.should match(/^env_/)
    end
    
    @cltns.each do |cltn|
      cltn.parent.name.should match(/^db_/)
    end
  end
  
  it "should set the path correctly" do
    @cltns.first.data[:path_names].should == "root|env_0|db_0|cltn_0"
    @dbs.last.data[:path_names].should    == "root|env_1|db_3"
    @envs.first.data[:path_names].should  == "root|env_0"
    @root.data[:path_names].should        be_nil
  end
  
  # it "should dump to json correctly" do    
  #   @cltns.first.to_json.should_not be_empty
  #   @dbs.first.to_json.should_not   be_empty
  # end
  
  it "should dump adjacencies correctly" do
    item = @cltns.first.to_adjacencies
    item.should have(1).item
    item.first[:name].should == "cltn_0"
    item.first[:id].should  == 102
    
    item = @dbs.first.to_adjacencies
    item.should have(5).item
    item.first[:name].should == 'db_0'
    item.last[:name].should  == 'cltn_3'    
    
    # @dbs.first.to_adjacencies.should   == 
    # [{:adjacencies=>[102, 103, 104, 105], :name=>"db_0", :id=>102, :data=>{:path_ids=>"0|100|102", :path_names=>"root|env_0|db_0"}}, {:adjacencies=>[], :name=>"cltn_0", :id=>102, :data=>{:path_ids=>"0|100|102|102", :path_names=>"root|env_0|db_0|cltn_0"}}, {:adjacencies=>[], :name=>"cltn_1", :id=>103, :data=>{:path_ids=>"0|100|102|103", :path_names=>"root|env_0|db_0|cltn_1"}}, {:adjacencies=>[], :name=>"cltn_2", :id=>104, :data=>{:path_ids=>"0|100|102|104", :path_names=>"root|env_0|db_0|cltn_2"}}, {:adjacencies=>[], :name=>"cltn_3", :id=>105, :data=>{:path_ids=>"0|100|102|105", :path_names=>"root|env_0|db_0|cltn_3"}}]
  end
  
  describe "slave node" do
    before :all do
      @node = Mongo3::Node.make_node( "fred" )
    end
    
    it "should mark a slave node correctly" do  
      @node.mark_slave!
      @node.data.has_key?( :master ).should == false      
      @node.data[:slave].should             == true
      @node.data['$dim'].should             == 15
      @node.data['$lineWidth'].should       == 3
      @node.data['$color'].should           == "#434343"
    end

    it "should detect a slave node correctly" do
      @node.should be_slave
    end
  end
  
  describe "master node" do  
    before :all do
      @node = Mongo3::Node.make_node( "fred" )
    end
    
    it "should mark a master not correctly" do
      @node.mark_master!
      @node.data.has_key?( :slave ).should == false
      @node.data[:master].should           == true
      @node.data['$dim'].should            == 15
      @node.data['$lineWidth'].should      == 3
      @node.data['$color'].should          == "#92b948"    
    end
    
    it "should detect a master node correctly" do
      @node.should be_master      
    end      
  end
end