require 'spec_helper'

module Cellect::Client
  describe NodeSet do
    it_behaves_like 'node set'
    let(:node_set){ Cellect::Client.node_set }

    #@note: node_set.nodes has state from intial code loading
    # the above def which is really a cached celluloid actor from boot
    # see Cellect::Client / Cellect::Server
    it 'should update the node list when changing' do
      begin
        pass_until node_set, is: :ready
        node_set.zk.create '/nodes/node', data: 'foo', mode: :ephemeral_sequential
        100.times do |i|
          break if node_set.nodes['node0000000001']
          Thread.pass
        end
        expect(node_set.nodes['node0000000001']).to eq 'foo'
      ensure
        node_set.zk.delete '/nodes/node0000000001'
      end
    end
  end
end
