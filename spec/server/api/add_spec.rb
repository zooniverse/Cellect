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

          it 'should handle invalid subject_ids' do
            bad_opts = opts.merge subject_id: '%(*ERRRR)'
            put "/workflows/#{ workflow_type }/add", bad_opts
            expect(last_response.status).to eql 400
            expect(last_response.body).to match /Bad Request/
          end

          it 'should handle invalid group_ids' do
            if workflow.grouped?
              bad_opts = opts.merge group_id: '%(*ERRRR)'
              put "/workflows/#{ workflow_type }/add", bad_opts
              expect(last_response.status).to eql 400
              expect(last_response.body).to match /Bad Request/
            else
              put "/workflows/#{ workflow_type }/add", opts
              expect(last_response).to be_ok
            end
          end

          it 'should handle invalid priorities' do
            bad_opts = opts.merge priority: '%(*ERRRR)'

            if workflow.prioritized?
              put "/workflows/#{ workflow_type }/add", bad_opts
              expect(last_response.status).to eql 400
              expect(last_response.body).to match /Bad Request/
            else
              put "/workflows/#{ workflow_type }/add", bad_opts
              expect(last_response).to be_ok
            end
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
