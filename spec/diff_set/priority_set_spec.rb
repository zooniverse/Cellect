require 'spec_helper'

module DiffSet
  describe PrioritySet do
    def create_set(elements)
      ids = (1..elements).to_a
      priorities = ids.reverse
      
      PrioritySet.new.tap do |priority_set|
        ids.zip(priorities).each{ |id, priority| priority_set.add id, priority }
      end
    end
    
    it_behaves_like 'set'
    let(:set){ create_set(5) }
    let(:other_set){ create_set(3) }
  end
end
