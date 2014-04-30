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
          
          let(:opts) do
            { subject_id: 123 }.tap do |h|
              h[:group_id] = 1 if project.grouped?
            end
          end
          
          it 'should remove subjects' do
            if project.grouped?
              project.should_receive(:remove).with subject_id: 123, group_id: 1, priority: nil
            else
              project.should_receive(:remove).with subject_id: 123, group_id: nil, priority: nil
            end
            
            put "/projects/#{ project_type }/remove", opts
            last_response.status.should == 200
          end
        end
      end
    end
  end
end
