module Cellect
  module Server
    class Loader
      include Celluloid

      attr_reader :workflow

      def initialize(workflow)
        @workflow = workflow
      end

      def load_data
        run_load!(workflow.subjects)
        mark_workflow_as_loaded
      end

      def reload_data(set)
        run_load!(set)
        workflow.subjects = set
        mark_workflow_as_loaded
      end

      private

      def mark_workflow_as_loaded
        workflow.set_reload_at_time
        workflow.state = :ready
      end

      def run_load!(set)
        Cellect::Server.adapter.load_data_for(workflow.name).each do |hash|
          set.add hash['id'], hash['priority']
        end
      end
    end
  end
end
