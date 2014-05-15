require 'spec_helper'

module Cellect::Client
  describe NodeSet do
    it_behaves_like 'node set'
    let(:node_set){ Cellect::Client.node_set }
    
    it 'should update the node list when changing' do
      pass_until node_set, is: :ready
      node_set.zk.create '/nodes/node', data: 'foo', mode: :ephemeral_sequential
      
      10.times do
        break if node_set.nodes['node0000000001']
        Thread.pass
      end
      
      node_set.nodes['node0000000001'].should == 'foo'
    end
  end
end
