shared_examples_for 'node set' do
  let(:node_set){ Cellect::NodeSet.new }
  
  it 'should connect to zoo keeper' do
    node_set.zk.should be_nil
    pass_until node_set, is: :ready
    node_set.zk.should be_connected
  end
  
  it 'should know the connection state' do
    node_set.state.should be :initializing
    pass_until node_set, is: :ready
    node_set.should be_ready
  end
  
  it 'should accept a connection string' do
    begin
      pass_until node_set, is: :ready
      ENV['ZK_URL'] = 'foobar'
      node_set.send(:zk_url).should == 'foobar'
      ENV.delete 'ZK_URL'
      node_set.send(:zk_url).should == 'localhost:2181'
    ensure
      ENV['ZK_URL'] = 'localhost:21811'
    end
  end
end
