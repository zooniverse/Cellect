require 'spec_helper'

module Cellect::Server
  describe Loader do
    SET_TYPES.each do |workflow_type|
      it_behaves_like "loader" do
        let(:workflow) { Workflow.new(workflow_type) }
        let(:loader) { Loader.new(workflow) }
        let(:subjects) { workflow.set_klass.new }

        describe "#load_data" do
          it "should add data to the workflow subjects" do
            expect(workflow.subjects)
              .to receive(:add)
              .exactly(fixture_count)
            loader.load_data
          end
        end

        describe "#reload_data" do
          it "should add data to the workflow subjects" do
            expect(subjects)
              .to receive(:add)
              .exactly(fixture_count)
            loader.reload_data(subjects)
          end
        end
      end
    end
  end
end
