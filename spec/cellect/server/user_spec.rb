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
      expect(user.bare_object).to receive(:restart_ttl_timer).at_least :once
      user.seen
    end

    it 'should terminate on ttl expiry' do
      async_workflow = double
      expect(Workflow[user.workflow_name]).to receive(:async).and_return async_workflow
      expect(async_workflow).to receive(:remove_user).with user.id
      user.ttl_expired!
      expect(user.ttl_timer).to be_nil
    end

    describe '#load_data' do
      it 'should request data from the adapater' do
        expect(Cellect::Server.adapter)
          .to receive(:load_user)
          .with(user.workflow_name, user.id)
          .and_return([])
        user.load_data
      end

      it 'should add data to seens' do
        expect { user.load_data }.to change { user.seen.size }
      end

      it 'should not add new subjects when already loaded' do
        user.load_data
        expect { user.load_data }.not_to change { user.seen.size }
      end
    end
  end
end
