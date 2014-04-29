require 'spec_helper'

module Cellect
  describe Project do
    PROJECT_TYPES.each do |project_type|
      context project_type do
        it_behaves_like 'stateful', :project
        it_behaves_like 'project', :project
        let(:project){ Project[project_type] }
        let(:user){ project.user 'foo' }
        
        it 'should provide unseen for users' do
          project.subjects.should_receive(:subtract).with user.seen, 3
          project.unseen_for 'foo', limit: 3
        end
        
        it 'should be notified of a user ttl expiry' do
          project.bare_object.should_receive(:remove_user).with user.name
          user.ttl_expired!
        end
        
        it 'should remove users when their ttl expires' do
          name = user.name
          project.remove_user name
          project.users.should_not have_key name
          expect{ user.name }.to raise_error
        end
      end
    end
  end
end
