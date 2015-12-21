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
  end
end
