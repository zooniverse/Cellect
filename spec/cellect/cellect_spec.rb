require 'spec_helper'

module Cellect
  describe Cellect do
    context 'default adapter' do
      let(:default){ Cellect::Adapters::Default.new }
      
      it 'should raise a NotImplementedError when using the default adapter' do
        expect{ default.project_list }.to raise_error NotImplementedError
        expect{ default.load_data_for(Project.new('test')) }.to raise_error NotImplementedError
        expect{ default.load_user 'random', 123 }.to raise_error NotImplementedError
      end
      
      it 'should return a project given a set of options' do
        default.project_for('name' => 'a').should be_an_instance_of Project
        default.project_for('name' => 'b', 'grouped' => true).should be_an_instance_of GroupedProject
        default.project_for('name' => 'c', 'pairwise' => true).should be_pairwise
        default.project_for('name' => 'd', 'prioritized' => true).should be_prioritized
        default.project_for('name' => 'e', 'pairwise' => true, 'prioritized' => true).should be_pairwise
        default.project_for('name' => 'e', 'pairwise' => true, 'prioritized' => true).should be_prioritized
      end
    end
    
    context 'node affinity' do
      after(:each){ Cellect.node_affinity = false }
      
      it 'should replicate by default' do
        Cellect.node_affinity.should be_false
        NodeSet.should_receive(:nodes).and_return a: 1
        Cellect::Replicator.any_instance.should_receive(:_replicate).with 1, 'foo', '/bar', ''
        Cellect.replicator.replicate 'foo', '/bar'
      end
      
      it 'should not replicate with node affinity' do
        Cellect.node_affinity = true
        NodeSet.should_not_receive :nodes
        Cellect.replicator.bare_object.should_not_receive :async
        Cellect.replicator.replicate 'foo', '/bar'
      end
    end
  end
end
