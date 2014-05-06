shared_examples_for 'stateful' do |name|
  let(:obj){ send name }
  
  it 'should not have a default state' do
    obj.class.any_instance.stub :load_data
    obj.class.new('new').state.should be_nil
  end
  
  it 'should have states' do
    obj.class.states.keys.should =~ [:initializing, :ready]
  end
  
  it 'should transition states' do
    pass_until obj, is: :ready
    expect{ obj.transition :initializing }.to change{ obj.state }.to :initializing
    expect{ obj.transition :ready }.to change{ obj.state }.to :ready
  end
  
  it 'should publish state transitions' do
    pass_until obj, is: :ready
    obj.bare_object.should_receive(:publish) do |topic, state|
      topic.should =~ /::state_change$/
      state.should be :initializing
    end
    
    obj.transition :initializing
  end
end
