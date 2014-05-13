require 'spec_helper'

module Cellect
  describe API do
    include_context 'API'
    
    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:project_type){ [grouping, set_type].compact.join '_' }
          let(:project){ Project[project_type] }
          before(:each){ pass_until project, is: :ready }
          
          it 'should load users' do
            async_project = double
            project.should_receive(:async).and_return async_project
            async_project.should_receive(:user).with 123
            post "/projects/#{ project_type }/users/123/load"
            last_response.status.should == 201
          end
          
          it 'should replicate loaded users' do
            path = "/projects/#{ project_type }/users/123/load"
            Cellect.replicator.should_receive(:replicate).with 'post', path, 'user_id=123&replicated=true'
            post path
            last_response.status.should == 201
          end
        end
      end
    end
  end
end
