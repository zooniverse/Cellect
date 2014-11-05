require 'spec_helper'

module Cellect::Server
  describe API do
    include_context 'API'
    
    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:workflow_type){ [grouping, set_type].compact.join '_' }
          let(:workflow){ Workflow[workflow_type] }
          before(:each){ pass_until workflow, is: :ready }
          
          it 'should load users' do
            async_workflow = double
            expect(workflow).to receive(:async).and_return async_workflow
            expect(async_workflow).to receive(:user).with 123
            post "/workflows/#{ workflow_type }/users/123/load"
            expect(last_response.status).to eq 201
          end
        end
      end
    end
  end
end
