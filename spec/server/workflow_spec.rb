require 'spec_helper'

module Cellect::Server
  describe Workflow do
    SET_TYPES.each do |workflow_type|
      context workflow_type do
        it_behaves_like 'workflow', :workflow
        let(:workflow){ Workflow[workflow_type] }
        let(:user){ workflow.user 123 }
        before(:each){ pass_until workflow, is: :ready }
        
        it 'should provide unseen for users' do
          workflow.subjects.should_receive(:subtract).with user.seen, 3
          workflow.unseen_for 123, limit: 3
        end
        
        it 'should sample subjects without a user' do
          workflow.subjects.should_receive(:sample).with 3
          workflow.sample limit: 3
        end
        
        it 'should sample subjects with a user' do
          workflow.subjects.should_receive(:subtract).with user.seen, 3
          workflow.sample user_id: 123, limit: 3
        end
        
        it 'should add subjects' do
          if workflow.prioritized?
            workflow.subjects.should_receive(:add).with 123, 456
            workflow.add subject_id: 123, priority: 456
          else
            workflow.subjects.should_receive(:add).with 123
            workflow.add subject_id: 123
          end
        end
        
        it 'should remove subjects' do
          workflow.subjects.should_receive(:add).with 123
          workflow.add subject_id: 123
        end
        
        it 'should be notified of a user ttl expiry' do
          async_workflow = double
          workflow.should_receive(:async).and_return async_workflow
          async_workflow.should_receive(:remove_user).with user.id
          user.ttl_expired!
        end
        
        it 'should remove users when their ttl expires' do
          id = user.id
          workflow.remove_user id
          workflow.users.should_not have_key id
          expect{ user.id }.to raise_error
        end
        
        it 'should not be grouped' do
          workflow.should_not be_grouped
        end
      end
    end
  end
end
