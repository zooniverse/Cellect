require 'spec_helper'

module DiffSet
  describe RandomSet do
    def create_set(elements)
      RandomSet.new.tap do |random_set|
        1.upto(elements).each{ |i| random_set.add i }
      end
    end
    
    let(:set){ create_set(5) }
    let(:other_set){ create_set(3) }
    
    it 'should convert to an Array' do
      set.to_a.should =~ (1..5).to_a
    end
    
    it 'should add elements' do
      set.add 100
      set.to_a.should include 100
    end
    
    it 'should remove elements' do
      set.remove 1
      set.to_a.should_not include 1
    end
    
    it 'should know how many elements it contains' do
      expect{ set.add 100 }.to change{ set.size }.from(5).to 6
    end
    
    it 'should know if it contains an element' do
      set.should_not include 100
      set.add 100
      set.should include 100
    end
    
    it 'should subtract another RandomSet' do
      set.subtract(other_set, 5).should =~ [4, 5]
      [4, 5].should include set.subtract(other_set, 1).first
    end
    
    it 'should mutate the order of the elements on a subtraction' do
      set_before = set.to_a
      set.subtract other_set, 5
      set_before.should =~ set.to_a
      set_before.should_not == set.to_a
    end
  end
end
