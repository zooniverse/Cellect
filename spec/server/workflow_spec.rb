require 'spec_helper'

module Cellect::Server
  describe Workflow do
    it "should try to load workflows that aren't loaded" do
      expect(Cellect::Server.adapter).to receive(:load_workflows).with('random').and_call_original
      Workflow['random']
    end
    
    SET_TYPES.each do |workflow_type|
      context workflow_type do
        it_behaves_like 'workflow', :workflow
        let(:workflow){ Workflow[workflow_type] }
        let(:user){ workflow.user 123 }
        before(:each){ pass_until workflow, is: :ready }
        
        it 'should provide unseen for users' do
          expect(workflow.subjects).to receive(:subtract).with user.seen, 3
          workflow.unseen_for 123, limit: 3
        end
        
        it 'should sample subjects without a user' do
          expect(workflow.subjects).to receive(:sample).with 3
          workflow.sample limit: 3
        end
        
        it 'should sample subjects with a user' do
          expect(workflow.subjects).to receive(:subtract).with user.seen, 3
          workflow.sample user_id: 123, limit: 3
        end
        
        it 'should add subjects' do
          if workflow.prioritized?
            expect(workflow.subjects).to receive(:add).with 123, 456
            workflow.add subject_id: 123, priority: 456
          else
            expect(workflow.subjects).to receive(:add).with 123
            workflow.add subject_id: 123
          end
        end
        
        it 'should remove subjects' do
          expect(workflow.subjects).to receive(:remove).with 123
          workflow.remove subject_id: 123
        end
        
        it 'should be notified of a user ttl expiry' do
          async_workflow = double
          expect(workflow).to receive(:async).and_return async_workflow
          expect(async_workflow).to receive(:remove_user).with user.id
          user.ttl_expired!
        end
        
        it 'should remove users when their ttl expires' do
          id = user.id
          workflow.remove_user id
          expect(workflow.users).to_not have_key id
          expect{ user.id }.to raise_error Celluloid::DeadActorError
        end
        
        it 'should not be grouped' do
          expect(workflow).to_not be_grouped
        end
      end
    end
  end
end
