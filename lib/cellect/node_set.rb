require 'socket'
require 'timeout'

module Cellect
  class NodeSet
    include Celluloid
    
    attr_accessor :zk, :state, :id
    
    def initialize
      self.state = :initializing
      after(0.001){ async.initialize_zk } # don't block waiting for ZK to connect
    end
    
    def initialize_zk
      # don't let ZK hang the thread, just retry connection on restart
      Timeout::timeout(5) do
        self.zk = ZK.new zk_url, chroot: '/cellect'
      end
      setup
      self.state = :ready
    end
    
    def ready?
      state == :ready
    end
    
    protected
    
    def zk_url
      ENV.fetch 'ZK_URL', 'localhost:2181'
    end
    
    def setup
      zk.mkdir_p '/nodes'
      ip = Socket.ip_address_list.find{ |address| address.ipv4? && !address.ipv4_loopback? }.ip_address
      path = zk.create '/nodes/node', data: ip, mode: :ephemeral_sequential
      self.id = path.sub /^\/nodes\//, ''
    end
  end
end
