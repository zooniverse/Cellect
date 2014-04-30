module Cellect
  class Project
    include Celluloid
    include Stateful
    
    attr_accessor :name, :users, :subjects
    attr_accessor :pairwise, :prioritized
    
    def self.[](name, pairwise: false, prioritized: false)
      Actor["project_#{ name }".to_sym] ||= new name, pairwise: pairwise, prioritized: prioritized
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
    
    def user(name)
      self.users[name] ||= User.new_link name, project_name: self.name
    end
    
    def unseen_for(user_name, limit: 5)
      subjects.subtract user(user_name).seen, limit
    end
    
    def add_seen_for(user_name, *subject_ids)
      [subject_ids].flatten.compact.each do |subject_id|
        user(user_name).seen.add subject_id
      end
    end
    
    def remove_user(name)
      removed = self.users.delete name
      return unless removed
      unlink removed
      removed.terminate
    end
    
    def sample(opts = { })
      subjects.sample opts[:limit]
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
