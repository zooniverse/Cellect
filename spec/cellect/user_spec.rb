require 'spec_helper'

module Cellect
  describe User do
    let(:user){ User.new 1, project_name: 'random' }
    
    it 'should store seen ids' do
      user.seen.should be_a DiffSet::RandomSet
    end
    
    it 'should have a default ttl of 15 minutes' do
      user.ttl.should == 900 # seconds
    end
    
    it 'should allow custom ttl' do
      User.new(2, project_name: 'random', ttl: 123).ttl.should == 123
    end
    
    it 'should reset the ttl timer on activity' do
      user.bare_object.should_receive(:restart_ttl_timer).at_least :once
      user.seen
    end
    
    it 'should terminate on ttl expiry' do
      user.bare_object.should_receive :terminate
      user.ttl_expired!
    end
  end
end
