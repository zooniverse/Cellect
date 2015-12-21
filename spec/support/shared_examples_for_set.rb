shared_examples_for 'a set' do
  it 'should convert to an Array' do
    expect(set.to_a).to eq (1..5).to_a
  end

  it 'should add elements' do
    set.add 100
    expect(set.to_a).to include 100
  end

  it 'should remove elements' do
    set.remove 1
    set.to_a.should_not include 1
  end

  it 'should sample elements' do
    expect(set.sample(2).length).to eq 2
  end

  it 'should not include removed elements in samples' do
    set.remove 5
    set.sample(5).should_not include 5
  end

  it 'should know how many elements it contains' do
    expect{ set.add 100 }.to change{ set.size }.from(5).to 6
  end

  it 'should know if it contains an element' do
    set.should_not include 100
    set.add 100
    expect(set).to include 100
  end
end
