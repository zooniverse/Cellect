require 'spec_helper'

module Cellect::Server
  describe NodeSet do
    it_behaves_like 'node set'
    let(:node_set){ Cellect::Server.node_set.actors.first }

    it 'should register this node' do
      expect(node_set.id).to eq 'node0000000000'
      expect(node_set.zk.get('/nodes/node0000000000').first).to match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    end
  end
end
