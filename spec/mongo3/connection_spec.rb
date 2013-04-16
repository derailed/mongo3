require File.expand_path( File.join( File.dirname(__FILE__), %w[.. spec_helper] ) )
require 'ostruct'
require 'mongo'

describe Mongo3::Connection do
  
  before( :all ) do
    @con    = Mongo::Connection.new( 'localhost', 12345 )
    @db     = @con.db( 'mongo3_test_db', :strict => true )
    @mongo3 = Mongo3::Connection.new( File.join(File.dirname(__FILE__), %w[.. configs landscape.yml]) )    
  end
  
  before( :each ) do    
    unless @db.collection_names.include? 'test1_cltn'
      @cltn1 = @db.create_collection('test1_cltn') 
    else
      @cltn1 = @db['test1_cltn']
    end
    unless @db.collection_names.include? 'test2_cltn'
      @cltn2 = @db.create_collection('test2_cltn') 
    else
      @cltn2 = @db['test2_cltn']
    end
    
    @cltn1.remove
    10.times do |i|
      @cltn1.insert( {:name => "test_#{i}", :value => i } )
    end
    @cltn2.remove
    10.times do |i|
      @cltn2.insert( {:name => "test_#{i}", :value => i } )
    end
  end

  # describe "configs" do
  #   before( :all ) do
  #     @crapola = Mongo3::Connection.new( File.join(File.dirname(__FILE__), %w[.. configs crap.yml]) )
  #   end
  # 
  #   it "should raise an error on bogus yml" do
  #     lambda {
  #       con = Mongo3::Connection.new( File.join(File.dirname(__FILE__), %w[.. configs hosed.yml]) )
  #       con.send( :config )
  #     }.should raise_error( /Unable to grok yaml landscape file/ )
  #   end
  #   
  #   it "should crap out if the zone host is missing correctly" do
  #     lambda {
  #       @crapola.send( :connect_for, "bozo" )
  #     }.should raise_error( /Unable to find `host/ )
  #   end    
  #   
  #   it "should crap out if the zone port is missing correctly" do
  #     lambda {
  #       @crapola.send( :connect_for, "blee" )
  #     }.should raise_error( /Unable to find `port/ )
  #   end    
  #   
  #   it "should crap out if the zone is not correctly configured" do
  #     lambda {
  #       @crapola.send( :connect_for, "nowhere" )
  #     }.should raise_error( /MongoDB connection failed for `"funky_town"/ )
  #   end    
  # end
  
  describe "zones" do
    it "should crap out if the zone does not exist" do
      lambda {
        @mongo3.send( :connect_for, "shit for brains" )
      }.should raise_error( /Unable to find zone/ )
    end
    
    it "should connect to a zone with auth correctly" do
      @mongo3.send( :connect_for, "admin" ) do |con|
        con.should_not be_nil
      end
    end    
  end
  
  describe "drop database" do  
    it "should drop a database correctly" do
      dbs = @con.database_names
      # Quirk? a db does not really exists unless it has a collection
      db = @con.db( "dead_meat" )
      db.create_collection( "dead_weight" )
      @con.database_names.should have( dbs.size + 1 ).items
      @mongo3.drop_db( "home|test|dead_meat" )
      @con.database_names.should have( dbs.size ).items    
    end
  end
  
  it "should clear out a cltn correctly" do
    @mongo3.clear_cltn( "home|test|mongo3_test_db|test1_cltn" )
    @db['test1_cltn'].count.should == 0
    @db['test2_cltn'].count.should == 10
  end
  
  it "should delete a row correctly" do
    before = @cltn1.count
    obj = @cltn1.find_one()
    @mongo3.delete_row( "home|test|mongo3_test_db|test1_cltn", obj['_id'].to_s )
    @db['test1_cltn'].count.should == before-1    
  end
  
  it "should drop a cltn correctly" do
    status = @mongo3.drop_cltn( "home|test|mongo3_test_db|test1_cltn" )
    lambda { @db['test1_cltn'] }.should raise_error( /Collection 'test1_cltn' doesn't exist/ )
  end
    
  it "should load a landscape file correctly" do
    test = @mongo3.landscape['test']
        
    test.should_not be_nil
    test['host'].should == 'localhost'
    test['port'].should == 12345
  end
  
  it "should build a tree correctly" do
    root = @mongo3.build_tree

    root.name.should == 'home'
    root.oid.should  == 'home'
    root.data[:path_names].should == 'home'
    
    children = root.children
    children.should have(2).item
    children.first.name.should  == 'test'
    
    test = children.last
    test.name.should == 'admin'
    test.oid.should  == 'admin'
    test.children.should be_empty
  end
  
  describe "#show" do
    it "should pull env info correctly" do
      info = @mongo3.show( "home|test" )
      info.size.should             == 8
      info[:title].should          == "test"
      info[:databases].size.should > 1
    end
    
    it "should pull db info correctly" do
      info = @mongo3.show( "home|test|mongo3_test_db" )
      info.size.should          == 14
      info[:collections].should == 4
      info[:title].should       == "mongo3_test_db"      
    end
    
    it "should pull cltn info correctly" do
      info = @mongo3.show( "home|test|mongo3_test_db|test1_cltn" )
      info.size.should    == 4
      info[:size].should  == 10
      info[:title].should == "test1_cltn"
    end
  end
  
  describe "#build_sub_tree" do
    it "should build a adjacencies from db correctly" do
      adjs = @mongo3.build_sub_tree( 100, "home|test" ).to_adjacencies
      adjs.should_not be_empty
      adjs.size.should > 1
      adjs.first[:name].should == 'test'
      adjs.first[:id].should   == 100
    end
    
    it "should build a adjacencies from cltn correctly" do
      adjs = @mongo3.build_sub_tree( 200, "home|test|mongo3_test_db" ).to_adjacencies
      adjs.size.should == 3
      adjs.first[:name].should == 'mongo3_test_db'
      adjs.first[:id].should   == 200
      adjs.first[:adjacencies].should have(2).items
    end    
    
    it "should build a partial tree correctly" do
      root = @mongo3.build_partial_tree( "home|test|mongo3_test_db" )
      root.find( "test_0" ).children.should have(2).items
    end
  end

  describe "paginate db" do
    it "should paginate a db correctly" do
      rows = @mongo3.paginate_db( "home|test|mongo3_test_db" )
      rows.size.should == 2
      rows.total_entries.should == 2
    end    
  end  
  
  describe "paginate cltn" do
    it "should paginate a cltn correctly" do
      rows = @mongo3.paginate_cltn( "home|test|mongo3_test_db|test1_cltn" )
      rows.size.should == 10
      rows.total_entries.should == 10
    end
    
    it "should paginate db with q correctly" do
      rows = @mongo3.paginate_cltn( "home|test|mongo3_test_db|test1_cltn", [{:value =>{'$gt' => 5 }}, []] )
      rows.size.should == 4
      rows.total_entries.should == 4
    end    
    
    it "should paginate db with regex q correctly" do
      pending do
        rows = @mongo3.paginate_cltn( "home|test|mongo3_test_db|test1_cltn", [{"name"=>"\/test_*\/", "value"=>{"$gt"=>5}}, []] )
        rows.size.should == 4
        rows.total_entries.should == 4
      end
    end    
    
  end  
  
  describe "slaves" do
    it "should differentiate with a zone path" do
      @mongo3.send( :slave_zone?, %w[home test] ).should == false
    end

    it "should differentiate with a db path" do
      @mongo3.send( :slave_zone?, %w[home test fred] ).should == false
    end

    it "should detect a slave zone correctly" do
      @mongo3.send( :slave_zone?, %w[home test test] ).should == true
    end
  end
  
  describe "indexes" do
    it "should list indexes correctly" do
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      indexes.should_not be_nil
      indexes.keys.should have(1).item
      indexes.keys.first.should == '_id_'
    end
    
    it "should add an index correctly" do
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      before = indexes.size
      @mongo3.create_index( "home|test|mongo3_test_db|test1_cltn", [[:name, Mongo::ASCENDING]], {:unique => true} )
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      indexes.size.should == before + 1
    end

    it "should add a compound index correctly" do
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      before = indexes.size
      @mongo3.create_index( "home|test|mongo3_test_db|test1_cltn", [[:name, Mongo::ASCENDING], [:_id, Mongo::DESCENDING]], {:unique => true} )
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      indexes.size.should == before + 1
    end
    
    it "should drop an index correctly" do
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      before = indexes.size
      @mongo3.drop_index( "home|test|mongo3_test_db|test1_cltn", "name_1"  )
      indexes = @mongo3.indexes_for( "home|test|mongo3_test_db|test1_cltn" )
      indexes.size.should == before - 1      
    end
  end
  
  it "should detect a collection correctly" do
    @mongo3.send( :cltn_request?, %w[blee duh] ).should == false
    @mongo3.send( :cltn_request?, %w[blee duh fred] ).should == true
  end
  
  describe "#zone_for" do
    it "should find a zone correctly" do
      @mongo3.send( :zone_for, "localhost", "12345" ).should == "test"
    end
    
    it "should fail if a zone does not exist" do
      @mongo3.send( :zone_for, "ghost", 27017 ).should be_nil
      @mongo3.send( :zone_for, "localhost", 8888 ).should be_nil      
    end
  end
end