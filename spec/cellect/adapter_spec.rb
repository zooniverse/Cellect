require 'spec_helper'

module Cellect
  describe Cellect do
    context 'default adapter' do
      let(:default){ Cellect::Adapters::Default.new }
      
      it 'should raise a NotImplementedError when using the default adapter' do
        expect{ default.load_project 'foo' }.to raise_error NotImplementedError
        expect{ default.load_user 123 }.to raise_error NotImplementedError
      end
      
      it 'should return a project given a set of options' do
        default.project_for('a').should be_an_instance_of Project
        default.project_for('b', 'grouped' => true).should be_an_instance_of GroupedProject
        default.project_for('c', pairwise: true).should be_pairwise
        default.project_for('d', prioritized: true).should be_prioritized
        default.project_for('e', pairwise: true, prioritized: true).should be_pairwise
        default.project_for('e', pairwise: true, prioritized: true).should be_prioritized
      end
    end
  end
end
