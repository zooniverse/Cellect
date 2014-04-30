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
          
          before(:each) do
            Cellect.adapter.load_project project_type
          end
          
          it 'should sample without a user, limit, or group' do
            project.should_receive(:sample).with(limit: 5, user_id: nil, group_id: nil).and_call_original
            get "/projects/#{ project_type }"
            last_response.status.should == 200
            json.should be_a Array
          end
          
          shoulda = grouping ? 'limit, group, and user' : 'limit and user'
          it "should sample with a #{ shoulda }" do
            group_id = grouping ? 1 : nil
            project.should_receive(:sample).with(limit: 3, user_id: 123, group_id: group_id).and_call_original
            get "/projects/#{ project_type }?limit=3&user_id=123#{ grouping ? '&group_id=1' : '' }"
            last_response.status.should == 200
            json.should be_a Array
          end
        end
      end
    end
  end
end
