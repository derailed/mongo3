require File.expand_path( File.join( File.dirname(__FILE__), %w[.. spec_helper] ) )
require 'ostruct'
require 'mongo'

describe Mongo3::Zone do
  
  before( :each ) do
    @zones = Mongo3::Zone.new( File.join(File.dirname(__FILE__), %w[.. configs landscape.yml] ) )
  end
  
  describe "#connect_for" do
    it "should connect to a zone correctly" do
      @zones.send( :connect_for, "home|test" ) do |con|
        con.should_not be_nil
      end
    end
    
    it "should connect to an admin zone correctly" do
      @zones.send( :connect_for, "home|admin" ) do |con|
        con.should_not be_nil
      end
    end    
  end
  
  describe "#zone_for" do
    it "should find a zone correctly" do
      @zones.send( :zone_for, "localhost", "12345" ).should == "test"
    end
    
    it "should fail if a zone does not exist" do
      @zones.send( :zone_for, "ghost", 27017 ).should be_nil
      @zones.send( :zone_for, "localhost", 8888 ).should be_nil      
    end
  end
  
  describe "configs" do
    before( :all ) do
      @crapola = Mongo3::Zone.new( File.join(File.dirname(__FILE__), %w[.. configs crap.yml]) )
    end

    it "should raise an error on bogus yml" do
      lambda {
        con = Mongo3::Zone.new( File.join(File.dirname(__FILE__), %w[.. configs hosed.yml]) )
        con.send( :config )
      }.should raise_error( /Unable to grok yaml landscape file/ )
    end
    
    it "should crap out if the zone host is missing correctly" do
      lambda {
        @crapola.send( :connect_for, "home|bozo" )
      }.should raise_error( /Unable to find `host/ )
    end    
    
    it "should crap out if the zone port is missing correctly" do
      lambda {
        @crapola.send( :connect_for, "home|blee" )
      }.should raise_error( /Unable to find `port/ )
    end    
    
    it "should crap out if the zone is not correctly configured" do
      lambda {
        @crapola.send( :connect_for, "home|nowhere" )
      }.should raise_error( /MongoDB connection failed for `funky_town/ )
    end
    
  end
  
end
  