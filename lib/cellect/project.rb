module Cellect
  class Project
    include Celluloid
    include Stateful
    
    attr_accessor :name, :users, :subjects
    attr_accessor :pairwise, :prioritized
    
    def self.[](name, pairwise: false, prioritized: false)
      Actor["project_#{ name }".to_sym] ||= new name, pairwise: pairwise, prioritized: prioritized
    end
    
    def self.names
      actor_names = Celluloid.actor_system.registry.names.collect &:to_s
      project_actors = actor_names.select{ |key| key =~ /^project_/ }
      project_actors.collect{ |name| name.sub(/^project_/, '').to_sym }
    end
    
    def self.all
      names.collect{ |name| Project[name] }
    end
    
    def initialize(name, pairwise: false, prioritized: false)
      self.name = name
      self.users = { }
      self.pairwise = !!pairwise
      self.prioritized = !!prioritized
      self.subjects = set_klass.new
    end
    
    def load_data
      transition :initializing
      self.subjects = set_klass.new
      Cellect.adapter.load_data_for(self).each do |hash|
        subjects.add hash['id'], hash['priority']
      end
      transition :ready
    end
    
    def user(id)
      self.users[id] ||= User.supervise id, project_name: name
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
      return unless removed
      unlink removed
      removed.terminate
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
        subjects: subjects.size
      }
    end
  end
end
