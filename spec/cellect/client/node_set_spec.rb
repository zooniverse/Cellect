require 'spec_helper'

module Cellect::Client
  describe NodeSet do
    let!(:node_set){ Cellect::Client.node_set }

    # Allow listener to subscribe to Redis
    def wait_for_listener
      pass_until(timeout: 3) do
        connection = Redis.new(url: Attention.options[:redis_url])
        _, listeners = connection.pubsub 'numsub', 'cellect:instance'
        listeners > 0
      end
    end

    # Allow redis to publish to listener
    def wait_for_nodes(count)
      pass_until(timeout: 3) do
        node_set.nodes.length == count
      end
    end

    it 'should initialize without nodes' do
      expect(node_set.nodes).to be_empty
    end

    it 'should update the node list when activating' do
      wait_for_listener
      Attention.activate
      wait_for_nodes 1
      expect(node_set.nodes).to_not be_empty
    end

    it 'should update the node list when deactivating' do
      wait_for_listener
      Attention.activate
      wait_for_nodes 1
      Attention.deactivate
      wait_for_nodes 0
      expect(node_set.nodes).to be_empty
    end
  end
end
