require 'spec_helper'

module Cellect::Server
  describe GroupedWorkflow do
    SET_TYPES.collect{ |type| "grouped_#{ type }" }.each do |workflow_type|
      context workflow_type do
        it_behaves_like 'workflow', :workflow
        let(:workflow){ GroupedWorkflow[workflow_type] }
        let(:user){ workflow.user 123 }
        let(:set_klass){ workflow.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet }
        before(:each){ pass_until workflow, is: :ready }
        
        it 'should provide unseen from a random group for users' do
          workflow.groups = { }
          workflow.groups[1] = set_klass.new
          workflow.groups[1].should_receive(:subtract).with user.seen, 3
          workflow.unseen_for 123, limit: 3
        end
        
        it 'should provide unseen from a specific group for users' do
          3.times{ |i| workflow.groups[i] = set_klass.new }
          workflow.group(1).should_receive(:subtract).with user.seen, 3
          workflow.unseen_for 123, group_id: 1, limit: 3
        end
        
        it 'should sample subjects from a random group without a user' do
          workflow.groups = { }
          workflow.groups[1] = set_klass.new
          workflow.group(1).should_receive(:sample).with 3
          workflow.sample limit: 3
        end
        
        it 'should sample subjects from a specific group without a user' do
          3.times{ |i| workflow.groups[i] = set_klass.new }
          workflow.group(1).should_receive(:sample).with 3
          workflow.sample group_id: 1, limit: 3
        end
        
        it 'should sample subjects from a random group for a user' do
          workflow.groups = { }
          workflow.groups[1] = set_klass.new
          workflow.groups[1].should_receive(:subtract).with user.seen, 3
          workflow.sample user_id: 123, limit: 3
        end
        
        it 'should sample subjects from a specific group for a user' do
          3.times{ |i| workflow.groups[i] = set_klass.new }
          workflow.group(1).should_receive(:subtract).with user.seen, 3
          workflow.sample user_id: 123, group_id: 1, limit: 3
        end
        
        it 'should add subjects' do
          workflow.groups[1] = set_klass.new
          
          if workflow.prioritized?
            workflow.groups[1].should_receive(:add).with 123, 456
            workflow.add subject_id: 123, group_id: 1, priority: 456
          else
            workflow.groups[1].should_receive(:add).with 123
            workflow.add subject_id: 123, group_id: 1
          end
        end
        
        it 'should remove subjects' do
          workflow.groups[1] = set_klass.new
          workflow.groups[1].should_receive(:remove).with 123
          workflow.remove subject_id: 123, group_id: 1
        end
        
        it 'should be grouped' do
          workflow.should be_grouped
        end
      end
    end
  end
end
