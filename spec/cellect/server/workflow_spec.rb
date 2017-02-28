require 'spec_helper'

module Cellect::Server
  describe Workflow do
    it "should try to load workflows that aren't loaded" do
      expect(Cellect::Server.adapter).to receive(:load_workflows).with('random').and_call_original
      Workflow['random']
    end

    SET_TYPES.each do |workflow_type|
      context workflow_type do
        let(:workflow) { Workflow.new(workflow_type) }
        let(:user) { workflow.user 123 }

        it_behaves_like 'workflow', :workflow do
          let(:obj) { workflow }
        end

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
          expect(Workflow[workflow.name]).to receive(:async).and_return async_workflow
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

        describe '#load_data' do
          it 'should request data from the adapater' do
            expect(Cellect::Server.adapter)
              .to receive(:load_data_for)
              .with(workflow.name)
              .and_return([])
            workflow.load_data
          end

          it 'should add data to subjects' do
            expect { workflow.load_data }.to change { workflow.subjects }
          end

          it 'should not reload subjects when already loaded' do
            workflow.load_data
            expect { workflow.load_data }.not_to change { workflow.subjects }
          end
        end

        describe '#reload_data' do
          let(:adapter) { Cellect::Server.adapter }

          it 'should request data from the adapater' do
            expect(adapter)
              .to receive(:load_data_for)
              .with(workflow.name)
              .and_return([])
            workflow.reload_data
          end

          it 'should add data to subjects' do
            expect { workflow.reload_data }.to change { workflow.subjects }
          end

          it 'should not reload subjects when state is reloading' do
            workflow.state = :reloading
            expect(adapter).not_to receive(:load_data_for)
            workflow.reload_data
          end
        end
      end
    end
  end
end
