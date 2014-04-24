require 'spec_helper'

module Cellect
  describe Project do
    it_behaves_like 'stateful', :project
    it_behaves_like 'project', :project
    let(:project){ Project.new 'test' }
    let(:user){ project.user 'foo' }
    
    it 'should provide unseen for users' do
      project.subjects.should_receive(:subtract).with user.seen, 3
      project.unseen_for 'foo', limit: 3
    end
  end
end
