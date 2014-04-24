require 'spec_helper'

module Cellect
  describe GroupedProject do
    it_behaves_like 'stateful', :project
    it_behaves_like 'project', :project
    let(:project){ GroupedProject.new 'test' }
    let(:user){ project.user 'foo' }
    
    it 'should provide unseen from a random group for users' do
      project.groups[1] = DiffSet::RandomSet.new
      project.group(1).should_receive(:subtract).with user.seen, 3
      project.unseen_for 'foo', limit: 3
    end
    
    it 'should provide unseen from a specific group for users' do
      3.times{ |i| project.groups[i] = DiffSet::RandomSet.new }
      project.group(1).should_receive(:subtract).with user.seen, 3
      project.unseen_for 'foo', group_id: 1, limit: 3
    end
  end
end
