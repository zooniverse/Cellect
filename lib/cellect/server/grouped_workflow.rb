module Cellect
  module Server
    class GroupedWorkflow < Workflow

      # Sets up the new workflow
      def initialize(name, pairwise: false, prioritized: false)
        self.subjects = { }
        super
      end

      def groups
        subjects
      end

      # Returns a group by id
      # if the group_id is supplied it will select this group
      # and load data if no group is know, however when
      # no group_id supplies, it selects a group at random
      # with an overall fall back to a new group if no groups exist
      def group(group_id = nil)
        group = if group_id
                  fetch_or_setup_group(group_id)
                else
                  subjects.values.sample
                end
        group || fetch_or_setup_group(group_id)
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
        add_group = fetch_or_setup_group(opts[:group_id])

        if prioritized?
          add_group.add opts[:subject_id], opts[:priority]
        else
          add_group.add opts[:subject_id]
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
        if group = subjects[opts[:group_id]]
          group.remove opts[:subject_id]
        end
      end

      # General information about this workflow
      def status
        # Get the number of subjects in each group
        group_counts = Hash[*subjects.collect{ |id, set| [id, set.size] }.flatten]

        super.merge({
          grouped: true,
          subjects: group_counts.values.inject(:+),
          groups: group_counts
        })
      end

      def grouped?
        true
      end

      private

      def data_loader
        GroupedLoader.new(self)
      end

      def fetch_or_setup_group(group_id)
        subjects[group_id] ||= set_klass.new
      end
    end
  end
end
