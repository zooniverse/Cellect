require 'zk'
require 'timeout'

module Cellect
  class NodeSet
    include Celluloid
    
    attr_accessor :zk, :state
    
    # Sets up the node set and starts connecting to ZooKeeper
    def initialize(zk_url = nil)
      @zk_url = zk_url
      self.state = :initializing
      after(0.001){ async.initialize_zk } # don't block waiting for ZK to connect
    end
    
    # Connect to ZooKeeper, setup this node, and change state
    def initialize_zk
      # don't let ZK hang the thread, just retry connection on restart
      self.zk = ZK.new zk_url, { timeout: 5, chroot: '/cellect' }
      setup
      self.state = :ready
    end
    
    def ready?
      state == :ready
    end
    
    protected
    
    def zk_url
      @zk_url || ENV.fetch('ZK_URL', 'localhost:2181')
    end
    
    def setup
      # Specialized in subclasses
    end
  end
end
