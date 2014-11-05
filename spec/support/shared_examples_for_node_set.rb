shared_examples_for 'node set' do
  let(:node_set){ Cellect::NodeSet.new }
  
  it 'should connect to zoo keeper' do
    expect(node_set.zk).to be_nil
    pass_until node_set, is: :ready
    expect(node_set.zk).to be_connected
  end
  
  it 'should know the connection state' do
    expect(node_set.state).to be :initializing
    pass_until node_set, is: :ready
    expect(node_set).to be_ready
  end
  
  it 'should accept a connection string' do
    begin
      pass_until node_set, is: :ready
      ENV['ZK_URL'] = 'foobar'
      expect(node_set.send(:zk_url)).to eq 'foobar'
      ENV.delete 'ZK_URL'
      expect(node_set.send(:zk_url)).to eq 'localhost:2181'
    ensure
      ENV['ZK_URL'] = 'localhost:21811'
    end
  end
end
