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
          before(:each){ pass_until_state_of workflow, is: :ready }

          let(:opts) do
            { subject_id: 123 }.tap do |h|
              h[:priority] = 456.0 if workflow.prioritized?
              h[:group_id] = 1 if workflow.grouped?
            end
          end

          it 'should add subjects' do
            if workflow.grouped? && workflow.prioritized?
              expect(workflow).to receive(:add).with subject_id: 123, group_id: 1, priority: 456.0
            elsif workflow.grouped?
              expect(workflow).to receive(:add).with subject_id: 123, group_id: 1, priority: nil
            elsif workflow.prioritized?
              expect(workflow).to receive(:add).with subject_id: 123, group_id: nil, priority: 456.0
            else
              expect(workflow).to receive(:add).with subject_id: 123, group_id: nil, priority: nil
            end

            put "/workflows/#{ workflow_type }/add", opts
            expect(last_response.status).to eq 200
          end
        end
      end
    end

    it 'should handle missing workflows' do
      allow(Workflow).to receive(:[]).with('missing').and_return nil
      put '/workflows/missing/add', subject_id: 123
      expect(last_response.status).to eql 404
      expect(last_response.body).to match /Not Found/
    end
  end
end
