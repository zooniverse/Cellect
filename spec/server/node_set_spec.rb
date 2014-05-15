require 'spec_helper'

module Cellect::Server
  describe NodeSet do
    it_behaves_like 'node set'
    let(:node_set){ Cellect::Server.node_set.actors.first }
    
    it 'should register this node' do
      node_set.id.should == 'node0000000000'
      node_set.zk.get('/nodes/node0000000000').first.should =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    end
  end
end
