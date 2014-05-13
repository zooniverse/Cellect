require 'spec_helper'

module Cellect
  describe API do
    include_context 'API'
    
    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:project_type){ [grouping, set_type].compact.join '_' }
          let(:project){ Project[project_type] }
          let(:user){ project.user 123 }
          before(:each){ pass_until project, is: :ready }
          
          it 'should add seen subjects' do
            async_project = double
            project.should_receive(:async).and_return async_project
            async_project.should_receive(:add_seen_for).with 123, 123
            put "/projects/#{ project_type }/add_seen", user_id: 123, subject_id: 123
            last_response.status.should == 200
          end
        end
      end
    end
  end
end
