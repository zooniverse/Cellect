require 'spec_helper'

module Cellect::Server
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
      async_project = double
      Project[user.project_name].should_receive(:async).and_return async_project
      async_project.should_receive(:remove_user).with user.id
      user.ttl_expired!
      user.ttl_timer.should be_nil
    end
  end
end
