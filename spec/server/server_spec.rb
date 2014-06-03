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
        default.workflow_for('name' => 'a').should be_an_instance_of Workflow
        default.workflow_for('name' => 'b', 'grouped' => true).should be_an_instance_of GroupedWorkflow
        default.workflow_for('name' => 'c', 'pairwise' => true).should be_pairwise
        default.workflow_for('name' => 'd', 'prioritized' => true).should be_prioritized
        default.workflow_for('name' => 'e', 'pairwise' => true, 'prioritized' => true).should be_pairwise
        default.workflow_for('name' => 'e', 'pairwise' => true, 'prioritized' => true).should be_prioritized
      end
    end
  end
end
