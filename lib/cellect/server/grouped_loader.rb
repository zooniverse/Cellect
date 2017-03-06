module Cellect
  module Server
    class GroupedLoader < Loader

      def run_load!(set)
        Cellect::Server.adapter.load_data_for(workflow.name) do |hash|
          set[hash['group_id']] ||= workflow.set_klass.new
          set[hash['group_id']].add hash['id'], hash['priority']
        end
      end
    end
  end
end
