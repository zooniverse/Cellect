require 'spec_helper'

module Cellect::Server
  describe Cellect do
    context 'default adapter' do
      let(:default){ Cellect::Server::Adapters::Default.new }

      it 'should raise a NotImplementedError when using the default adapter' do
        expect{ default.workflow_list }.to raise_error NotImplementedError
        expect{ default.load_data_for(Workflow.new('test')) }.to raise_error NotImplementedError
        expect{ default.load_user 'random', 123 }.to raise_error NotImplementedError
      end

      it 'should return a workflow given a set of options' do
        expect(default.workflow_for('name' => 'a')).to be_an_instance_of Workflow
        expect(default.workflow_for('name' => 'b', 'grouped' => true)).to be_an_instance_of GroupedWorkflow
        expect(default.workflow_for('name' => 'c', 'pairwise' => true)).to be_pairwise
        expect(default.workflow_for('name' => 'd', 'prioritized' => true)).to be_prioritized
        expect(default.workflow_for('name' => 'e', 'pairwise' => true, 'prioritized' => true)).to be_pairwise
        expect(default.workflow_for('name' => 'e', 'pairwise' => true, 'prioritized' => true)).to be_prioritized
      end
    end

    describe '/stats' do
      include_context 'API'

      let(:response){ JSON.parse last_response.body }
      let(:all_workflows) do
        [].tap do |list|
          { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
            SET_TYPES.each do |set_type|
              workflow_type = [grouping, set_type].compact.join '_'
              list << Workflow[workflow_type]
            end
          end
        end
      end

      before(:each) do
        pass_until{ all_workflows.all? &:ready? }
        get '/stats'
      end

      it 'should include information' do
        expect(response.keys).to match_array %w(memory cpu node_set status)
      end

      context 'node_set' do
        let(:node_set){ response['node_set'] }

        it 'should include information' do
          expect(node_set['id']).to eql 'node0000000000'
          expect(node_set['ready']).to eql true
        end
      end

      context 'status' do
        let(:status){ response['status'] }

        it 'should include the aggregate workflow status' do
          expect(status['workflows_ready']).to eql true
        end

        context 'workflows' do
          let(:workflows){ status['workflows'] }

          it 'should include all workflow statuses' do
            expect(workflows.length).to eql all_workflows.length
          end
        end
      end
    end
  end
end
