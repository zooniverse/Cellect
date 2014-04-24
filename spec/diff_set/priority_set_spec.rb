require 'spec_helper'

module DiffSet
  describe PrioritySet do
    def create_set(elements)
      PrioritySet.new.tap do |random_set|
        1.upto(elements).each{ |i| random_set.add i }
      end
    end
    
    it_behaves_like 'set'
    let(:set){ create_set(5) }
    let(:other_set){ create_set(3) }
  end
end
