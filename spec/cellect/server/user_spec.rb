require 'spec_helper'

module Cellect::Server
  describe User do
    let(:user){ User.new 1, workflow_name: 'random' }

    it 'should store seen ids' do
      expect(user.seen).to be_a DiffSet::RandomSet
    end

    it 'should have a default ttl of 15 minutes' do
      expect(user.ttl).to eq 900 # seconds
    end

    it 'should allow custom ttl' do
      expect(User.new(2, workflow_name: 'random', ttl: 123).ttl).to eq 123
    end

    it 'should reset the ttl timer on activity' do
      expect(user).to receive(:restart_ttl_timer).at_least :once
      user.seen
    end

    it 'should terminate on ttl expiry' do
      async_workflow = double
      expect(Workflow[user.workflow_name]).to receive(:async).and_return async_workflow
      expect(async_workflow).to receive(:remove_user).with user.id
      user.ttl_expired!
      expect(user.ttl_timer).to be_nil
    end
  end
end
