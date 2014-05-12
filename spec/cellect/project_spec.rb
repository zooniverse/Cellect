require 'spec_helper'

module Cellect
  describe Project do
    SET_TYPES.each do |project_type|
      context project_type do
        it_behaves_like 'project', :project
        let(:project){ Project[project_type] }
        let(:user){ project.user 123 }
        before(:each){ pass_until project, is: :ready }
        
        it 'should provide unseen for users' do
          project.subjects.should_receive(:subtract).with user.seen, 3
          project.unseen_for 123, limit: 3
        end
        
        it 'should sample subjects without a user' do
          project.subjects.should_receive(:sample).with 3
          project.sample limit: 3
        end
        
        it 'should sample subjects with a user' do
          project.subjects.should_receive(:subtract).with user.seen, 3
          project.sample user_id: 123, limit: 3
        end
        
        it 'should add subjects' do
          if project.prioritized?
            project.subjects.should_receive(:add).with 123, 456
            project.add subject_id: 123, priority: 456
          else
            project.subjects.should_receive(:add).with 123
            project.add subject_id: 123
          end
        end
        
        it 'should remove subjects' do
          project.subjects.should_receive(:add).with 123
          project.add subject_id: 123
        end
        
        it 'should be notified of a user ttl expiry' do
          async_project = double
          project.should_receive(:async).and_return async_project
          async_project.should_receive(:remove_user).with user.id
          user.ttl_expired!
        end
        
        it 'should remove users when their ttl expires' do
          id = user.id
          project.remove_user id
          project.users.should_not have_key id
          expect{ user.id }.to raise_error
        end
        
        it 'should not be grouped' do
          project.should_not be_grouped
        end
      end
    end
  end
end
