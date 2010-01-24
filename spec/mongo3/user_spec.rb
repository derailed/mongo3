require File.expand_path( File.join( File.dirname(__FILE__), %w[.. spec_helper] ) )
require 'ostruct'
require 'mongo'

describe Mongo3::User do
  
  before( :each ) do
    @users = Mongo3::User.new( File.join(File.dirname(__FILE__), %w[.. configs landscape.yml] ) )
    @users.clear!( "home|test" )
    @users.list( "home|test", 1 ).should have(0).items
  end
  
  describe "#add" do
    it "should add users correctly" do
      result = @users.add( "home|test", "fred", "blee" )
      result.should_not                    be_nil    
      @users.list( "home|test", 1 ).should have(1).item      
    end
    
    it "should crap out if a user exists" do
      result = @users.add( "home|test", "fred", "blee" )
      result.should_not                          be_nil    
      @users.list( "home|test", 1 ).should have(1).item      
      lambda {
        @users.add( "home|test", "fred", "blee" )
      }.should raise_error( /User fred already exists!/ )
    end    
  end
    
  it "should clear out users correctly" do
    10.times { |i| @users.add( "home|test", "fred_#{i}", "secret" ) }
    @users.list( "home|test", 1 ).should have(10).items
    @users.clear!( "home|test" )
    @users.list( "home|test", 1 ).should have(0).item
  end
  
  describe "#delete" do
    it "should delete a user correctly" do
      user_ids = []
      10.times { |i| user_ids << @users.add( "home|test", "fred_#{i}", "secret" ) }
      
      count = 1
      user_ids.each do |id|
        result = @users.delete( "home|test", id.to_s )
        result.should_not be_nil
        @users.list( "home|test", 1 ).should have(10-count).items
        count += 1
      end
    end
  end
  
  describe "#list" do
    it "should list users correctly" do
      users = @users.list( "home|test", 1 )
      users.should have(0).items
    end
    
    it "should paginate users correctly" do
      10.times { |i| @users.add( "home|test", "fred_#{i}", "secret" ) }      
      users = @users.list( "home|test", 1, 2 )
      users.should have(2).items
      users.total_pages.should == 5
      users.total_entries.should == 10
    end    
  end  
  
  it "it should rename a user correctly" do
    pending do
      @users.rename( "home|test", "fred", "blee" )
    end
  end
end