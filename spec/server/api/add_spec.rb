require 'spec_helper'

module Cellect::Server
  describe API do
    include_context 'API'
    
    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:project_type){ [grouping, set_type].compact.join '_' }
          let(:project){ Project[project_type] }
          let(:user){ project.user 123 }
          before(:each){ pass_until project, is: :ready }
          
          let(:opts) do
            { subject_id: 123 }.tap do |h|
              h[:priority] = 456.0 if project.prioritized?
              h[:group_id] = 1 if project.grouped?
            end
          end
          
          it 'should add subjects' do
            if project.grouped? && project.prioritized?
              project.should_receive(:add).with subject_id: 123, group_id: 1, priority: 456.0
            elsif project.grouped?
              project.should_receive(:add).with subject_id: 123, group_id: 1, priority: nil
            elsif project.prioritized?
              project.should_receive(:add).with subject_id: 123, group_id: nil, priority: 456.0
            else
              project.should_receive(:add).with subject_id: 123, group_id: nil, priority: nil
            end
            
            put "/projects/#{ project_type }/add", opts
            last_response.status.should == 200
          end
        end
      end
    end
  end
end
