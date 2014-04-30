module Cellect
  module Adapters
    class Default
      # Return a list of projects to load in the form:
      #   [{
      #     'id' => 123,
      #     'name' => 'foo',
      #     'prioritized' => false,
      #     'pairwise' => false,
      #     'grouped' => false
      #   }, ...]
      def project_list
        raise NotImplementedError
      end
      
      # Load the data for a project, this method:
      #   Accepts a project
      #   Returns an array of hashes in the form:
      #   {
      #     'id' => 123,
      #     'priority' => 0.123,
      #     'group_id' => 456
      #   }
      def load_data_for(project)
        raise NotImplementedError
      end
      
      def load_user(id)
        raise NotImplementedError
      end
      
      def load_projects
        project_list.each{ |project_info| load_project project_info }
      end
      
      def load_project(args)
        if args.is_a?(Hash)
          project_for(args).async.load_data
        elsif args.is_a?(String)
          project_info = project_list.select{ |h| h['name'] == args }.first
          project_for(project_info).async.load_data
        else
          raise ArgumentError
        end
      end
      
      def project_for(opts = { })
        project_klass = opts.fetch('grouped', false) ? GroupedProject : Project
        project_klass[opts['name'], pairwise: opts['pairwise'], prioritized: opts['prioritized']]
      end
    end
  end
end
