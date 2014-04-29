module Cellect
  module Adapters
    class Default
      include Celluloid
      # Return a list of projects to load in the form:
      #   [{
      #     id: 123,
      #     name: 'foo',
      #     prioritized: false,
      #     pairwise: false,
      #     grouped: false
      #   }, ...]
      def project_list
        raise NotImplementedError
      end
      
      # Load the data for a project, this method should:
      #   Create the project
      #   Set project.pairwise and project.priority
      #   yield an array of hashes in the form:
      #   {
      #     id: 123,
      #     priority: 0.123,
      #     group_id: 456
      #   }
      def load_project(name)
        raise NotImplementedError
      end
      
      def load_user(id)
        raise NotImplementedError
      end
      
      def load_projects
        project_list.each{ |name| async.load_project name }
      end
      
      def project_for(name, opts = { })
        opts = opts.with_indifferent_access
        project_klass = opts.fetch(:grouped, false) ? GroupedProject : Project
        project_klass[name].tap do |project|
          project.pairwise = opts.fetch :pairwise, false
          project.prioritized = opts.fetch :prioritized, false
        end
      end
    end
  end
end
