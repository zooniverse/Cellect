require 'spec_helper'

module Cellect::Server
  describe Loader do
    SET_TYPES.collect{ |type| "grouped_#{ type }" }.each do |workflow_type|
      it_behaves_like "loader" do
        let(:workflow) { GroupedWorkflow.new(workflow_type) }
        let(:loader) { GroupedLoader.new(workflow) }
        let(:subjects) { {} }
        let(:group_counts) do
          fixtures.map { |f| f["group_id"] }.uniq.count
        end

        describe "#load_data" do
          it "should setup the groups" do
            expect(workflow.subjects)
              .to receive(:[]=)
              .exactly(group_counts)
              .and_call_original
            loader.load_data
          end

          it "should add data to the workflow subjects" do
            set = workflow.set_klass.new
            allow(workflow.set_klass)
              .to receive(:new)
              .and_return(set)
            expect(set)
              .to receive(:add)
              .exactly(fixture_count)
            loader.load_data
          end
        end

        describe "#reload_data" do
          it "should add data to the workflow subjects" do
            expect(subjects)
              .to receive(:[]=)
              .exactly(group_counts)
              .and_call_original
            loader.reload_data(subjects)
          end
        end
      end
    end
  end
end
