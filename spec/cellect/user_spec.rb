require 'spec_helper'

module Cellect
  describe User do
    it_behaves_like 'stateful', :user
    let(:user){ User.new 'test' }
    
    it 'should store seen ids' do
      user.seen.should be_a DiffSet::RandomSet
    end
    
    it 'should have a default ttl of 1 hour' do
      user.ttl.should == 3_600 # seconds
    end
    
    it 'should allow custom ttl' do
      User.new('test', ttl: 123).ttl.should == 123
    end
    
    it 'should not start the timer until data is loaded' do
      user.bare_object.should_not_receive :restart_ttl_timer
      user.transition :initializing
      user.ttl_timer.should be_nil
    end
    
    it 'should start the ttl timer after loading data' do
      user.bare_object.should_receive(:restart_ttl_timer).and_call_original
      user.transition :ready
      user.ttl_timer.offset.should be_within(1).of user.ttl
    end
    
    it 'should reset the ttl timer on activity' do
      user.bare_object.should_receive :restart_ttl_timer
      user.seen
    end
    
    it 'should terminate on ttl expiry' do
      user.bare_object.should_receive :terminate
      user.ttl_expired!
    end
  end
end
