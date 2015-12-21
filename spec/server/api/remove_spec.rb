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

          let(:opts) do
            { subject_id: 123 }.tap do |h|
              h[:group_id] = 1 if workflow.grouped?
            end
          end

          it 'should remove subjects' do
            if workflow.grouped?
              expect(workflow).to receive(:remove).with subject_id: 123, group_id: 1, priority: nil
            else
              expect(workflow).to receive(:remove).with subject_id: 123, group_id: nil, priority: nil
            end

            put "/workflows/#{ workflow_type }/remove", opts
            expect(last_response.status).to eq 200
          end
        end
      end
    end
  end
end
