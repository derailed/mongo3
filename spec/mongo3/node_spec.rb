require File.join(File.dirname(__FILE__), %w[.. spec_helper])
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
    @cltns.first.data[:path].should == "root|env_0|db_0|cltn_0"
    @dbs.last.data[:path].should    == "root|env_1|db_3"
    @envs.first.data[:path].should  == "root|env_0"
    @root.data[:path].should        be_nil
  end
  
  it "should dump to json correctly" do
    @cltns.first.to_json.should == "{\"name\":\"cltn_0\",\"id\":102,\"children\":[],\"data\":{\"path\":\"root|env_0|db_0|cltn_0\"}}"
    @dbs.first.to_json.should   == "{\"name\":\"db_0\",\"id\":102,\"children\":[{\"name\":\"cltn_0\",\"id\":102,\"children\":[],\"data\":{\"path\":\"root|env_0|db_0|cltn_0\"}},{\"name\":\"cltn_1\",\"id\":103,\"children\":[],\"data\":{\"path\":\"root|env_0|db_0|cltn_1\"}},{\"name\":\"cltn_2\",\"id\":104,\"children\":[],\"data\":{\"path\":\"root|env_0|db_0|cltn_2\"}},{\"name\":\"cltn_3\",\"id\":105,\"children\":[],\"data\":{\"path\":\"root|env_0|db_0|cltn_3\"}}],\"data\":{\"path\":\"root|env_0|db_0\"}}"
  end
  
  it "should dump adjacencies correctly" do
    @cltns.first.to_adjacencies.should == [{:adjacencies=>[], :name=>"cltn_0", :data=>{:path=>"root|env_0|db_0|cltn_0"}, :id=>102}]
    @dbs.first.to_adjacencies.should   == [{:name=>"db_0", :adjacencies=>[102, 103, 104, 105], :data=>{:path=>"root|env_0|db_0"}, :id=>102}, {:name=>"cltn_0", :adjacencies=>[], :data=>{:path=>"root|env_0|db_0|cltn_0"}, :id=>102}, {:name=>"cltn_1", :adjacencies=>[], :data=>{:path=>"root|env_0|db_0|cltn_1"}, :id=>103}, {:name=>"cltn_2", :adjacencies=>[], :data=>{:path=>"root|env_0|db_0|cltn_2"}, :id=>104}, {:name=>"cltn_3", :adjacencies=>[], :data=>{:path=>"root|env_0|db_0|cltn_3"}, :id=>105}] 
  end
end