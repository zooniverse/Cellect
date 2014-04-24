module Cellect
  module Stateful
    def self.included(klass)
      klass.class_eval do
        klass.send :include, Celluloid::FSM
        klass.send :include, Celluloid::Notifications
        
        state :initializing
        state :ready
        
        def self.inherited(descendant)
          descendant.class_eval do
            state :initializing
            state :ready
          end
        end
        
        def transition(new_state, opts = { })
          super(new_state, opts).tap do
            publish "#{ self.class.name.split('::').last }::state_change", new_state
          end
        end
      end
    end
  end
end
