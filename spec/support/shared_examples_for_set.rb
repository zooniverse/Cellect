shared_examples_for 'set' do
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
  
  it 'should subtract another set' do
    set.subtract(other_set, 5).should =~ [4, 5]
    [4, 5].should include set.subtract(other_set, 1).first
  end
  
  it 'should not include removed elements in subtractions' do
    set.remove 5
    set.subtract(other_set, 5).should == [4]
  end
end
