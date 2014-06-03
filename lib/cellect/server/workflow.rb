module Cellect
  module Server
    class Workflow
      include Celluloid
      
      attr_accessor :name, :users, :subjects, :state
      attr_accessor :pairwise, :prioritized
      
      def self.[](name, pairwise: false, prioritized: false)
        key = "workflow_#{ name }".to_sym
        Actor[key] ||= supervise name, pairwise: pairwise, prioritized: prioritized
        Actor[key].actors.first
      end
      
      def self.names
        actor_names = Celluloid.actor_system.registry.names.collect &:to_s
        workflow_actors = actor_names.select{ |key| key =~ /^workflow_/ }
        workflow_actors.collect{ |name| name.sub(/^workflow_/, '').to_sym }
      end
      
      def self.all
        names.collect{ |name| Workflow[name] }
      end
      
      def initialize(name, pairwise: false, prioritized: false)
        self.name = name
        self.users = { }
        self.pairwise = !!pairwise
        self.prioritized = !!prioritized
        self.subjects = set_klass.new
        load_data
      end
      
      def load_data
        self.state = :initializing
        self.subjects = set_klass.new
        Cellect::Server.adapter.load_data_for(name).each do |hash|
          subjects.add hash['id'], hash['priority']
        end
        self.state = :ready
      end
      
      def user(id)
        self.users[id] ||= User.supervise id, workflow_name: name
        users[id].actors.first
      end
      
      def unseen_for(user_id, limit: 5)
        subjects.subtract user(user_id).seen, limit
      end
      
      def add_seen_for(user_id, *subject_ids)
        [subject_ids].flatten.compact.each do |subject_id|
          user(user_id).seen.add subject_id
        end
      end
      
      def remove_user(user_id)
        removed = self.users.delete user_id
        removed.terminate if removed
      end
      
      def sample(opts = { })
        if opts[:user_id]
          unseen_for opts[:user_id], limit: opts[:limit]
        else
          subjects.sample opts[:limit]
        end
      end
      
      def add(opts = { })
        if prioritized?
          subjects.add opts[:subject_id], opts[:priority]
        else
          subjects.add opts[:subject_id]
        end
      end
      
      def remove(opts = { })
        subjects.remove opts[:subject_id]
      end
      
      def pairwise?
        !!pairwise
      end
      
      def prioritized?
        !!prioritized
      end
      
      def grouped?
        false
      end
      
      def ready?
        state == :ready
      end
      
      SET_KLASS = {
        # priority, pairwise
        [    false, false  ] => DiffSet::RandomSet,
        [    false, true   ] => DiffSet::PairwiseRandomSet,
        [     true, false  ] => DiffSet::PrioritySet,
        [     true, true   ] => DiffSet::PairwisePrioritySet
      }
      
      def set_klass
        SET_KLASS[[prioritized, pairwise]]
      end
      
      def status
        {
          state: state,
          grouped: false,
          prioritized: prioritized,
          pairwise: pairwise,
          subjects: subjects.size,
          users: users.length
        }
      end
    end
  end
end
