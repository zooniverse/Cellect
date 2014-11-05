require 'spec_helper'

module Cellect::Server
  describe API do
    include_context 'API'
    
    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:workflow_type){ [grouping, set_type].compact.join '_' }
          let(:workflow){ Workflow[workflow_type] }
          let(:user){ workflow.user 123 }
          before(:each){ pass_until workflow, is: :ready }
          
          it 'should sample without a user, limit, or group' do
            expect(workflow).to receive(:sample).with(limit: 5, user_id: nil, group_id: nil).and_call_original
            get "/workflows/#{ workflow_type }"
            expect(last_response.status).to eq 200
            expect(json).to be_a Array
          end
          
          shoulda = grouping ? 'limit, group, and user' : 'limit and user'
          it "should sample with a #{ shoulda }" do
            group_id = grouping ? 1 : nil
            expect(workflow).to receive(:sample).with(limit: 3, user_id: 123, group_id: group_id).and_call_original
            get "/workflows/#{ workflow_type }?limit=3&user_id=123#{ grouping ? '&group_id=1' : '' }"
            expect(last_response.status).to eq 200
            expect(json).to be_a Array
          end
        end
      end
    end
  end
end
