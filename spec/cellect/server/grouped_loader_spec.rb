require 'spec_helper'

module Cellect::Server
  describe Loader do
    SET_TYPES.collect{ |type| "grouped_#{ type }" }.each do |workflow_type|
      it_behaves_like "loader" do
        let(:workflow) { GroupedWorkflow.new(workflow_type) }
        let(:loader) { GroupedLoader.new(workflow) }
        let(:subjects) { {} }
        let(:load_method) { :[]= }
      end
    end
  end
end
