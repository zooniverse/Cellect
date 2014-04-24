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
    
    it 'should update the priority' do
      set.to_a.first.should == 1
      set.to_h[1].should be_within(0.1).of(5)
      set.add 1, 0
      set.to_a.first.should == 2
      set.to_a.last.should == 1
      set.to_h[1].should be_within(0.1).of(0)
    end
  end
end
