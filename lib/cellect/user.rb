require 'oj'

module Cellect
  class User
    include Celluloid
    include Stateful
    
    attr_accessor :name, :seen
    
    def initialize(name)
      self.name = name
      self.seen = DiffSet::RandomSet.new
      transition :ready
    end
  end
end
