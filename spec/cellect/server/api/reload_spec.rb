require 'spec_helper'

module Cellect::Server
  describe API do
    include_context 'API'

    { 'Ungrouped' => nil, 'Grouped' => 'grouped' }.each_pair do |grouping_type, grouping|
      SET_TYPES.shuffle.each do |set_type|
        context "#{ grouping_type } #{ set_type }" do
          let(:workflow_type){ [grouping, set_type].compact.join '_' }
          let(:workflow){ Workflow[workflow_type] }
          before(:each){ pass_until_state_of workflow, is: :ready }

          it 'should call reload_data' do
            async_workflow = double
            expect(workflow).to receive(:async).and_return async_workflow
            expect(async_workflow).to receive(:reload_data)
            post "/workflows/#{ workflow_type }/reload"
            expect(last_response.status).to eq 201
            expect(json).to be_nil
          end
        end
      end
    end
  end
end
