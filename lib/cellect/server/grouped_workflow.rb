module Cellect
  module Server
    class GroupedWorkflow < Workflow
      attr_accessor :groups

      # Sets up the new workflow
      def initialize(name, pairwise: false, prioritized: false)
        self.groups = { }
        super
      end

      # Load subjects from the adapter into their groups
      def load_data
        self.state = :initializing
        self.groups = { }
        klass = set_klass
        Cellect::Server.adapter.load_data_for(name).each do |hash|
          self.groups[hash['group_id']] ||= klass.new
          self.groups[hash['group_id']].add hash['id'], hash['priority']
        end
        self.state = :ready
      end

      # Returns a group by id or samples one randomly
      def group(group_id = nil)
        groups[group_id] || groups.values.sample
      end

      # Get unseen subjects from a group for a user
      def unseen_for(user_name, group_id: nil, limit: 5)
        group(group_id).subtract user(user_name).seen, limit
      end

      # Get a sample of subjects from a group for a user
      # 
      # Accepts a hash in the form:
      #   {
      #     user_id: 123,
      #     group_id: 2,
      #     limit: 5
      #   }
      def sample(opts = { })
        if opts[:user_id]
          unseen_for opts[:user_id], group_id: opts[:group_id], limit: opts[:limit]
        else
           group(opts[:group_id]).sample opts[:limit]
        end
      end

      # Adds or updates a subject in a group
      # 
      # Accepts a hash in the form:
      # {
      #   subject_id: 1,
      #   group_id: 2,
      #   priority: 0.5  # (if the workflow is prioritized)
      # }
      def add(opts = { })
        if prioritized?
          groups[opts[:group_id]].add opts[:subject_id], opts[:priority]
        else
          groups[opts[:group_id]].add opts[:subject_id]
        end
      end

      # Removes a subject from a group
      # 
      # Accepts a hash in the form:
      # {
      #   group_id: 1,
      #   subject_id: 2
      # }
      def remove(opts = { })
        groups[opts[:group_id]].remove opts[:subject_id]
      end

      # General information about this workflow
      def status
        # Get the number of subjects in each group
        group_counts = Hash[*groups.collect{ |id, set| [id, set.size] }.flatten]

        super.merge({
          grouped: true,
          subjects: group_counts.values.inject(:+),
          groups: group_counts
        })
      end

      def grouped?
        true
      end
    end
  end
end
