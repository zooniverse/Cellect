require 'spec_helper'

module Cellect::Server
  describe Loader do
    SET_TYPES.each do |workflow_type|
      it_behaves_like "loader" do
        let(:workflow) { Workflow.new(workflow_type) }
        let(:loader) { Loader.new(workflow) }
        let(:subjects) { workflow.set_klass.new }
        let(:load_method) { :add }
      end
    end
  end
end
