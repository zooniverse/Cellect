require 'socket'

module Cellect
  class Replicator
    include Celluloid
    
    attr_accessor :zk, :id, :instances
    
    def initialize
      self.zk = ZK.new zk_url, chroot: '/cellect'
      self.instances = { }
      watch_instances
      setup
    end
    
    protected
    
    def zk_url
      ENV.fetch 'ZK_URL', 'localhost:2181'
    end
    
    def instances_changed(nodes)
      self.instances = { }
      nodes.each do |node|
        next if node == id
        self.instances[node] = zk.get("/nodes/#{ node }").first
      end
    end
    
    def setup
      zk.mkdir_p '/nodes'
      zk.children '/nodes', watch: true
      register_instance
    end
    
    def watch_instances
      zk.register('/nodes') do |event|
        instances_changed zk.children('/nodes', watch: true)
      end
    end
    
    def register_instance
      ip = Socket.ip_address_list.find{ |address| address.ipv4? && !address.ipv4_loopback? }.ip_address
      path = zk.create '/nodes/node', data: ip, mode: :ephemeral_sequential
      self.id = path.sub /^\/nodes\//, ''
    end
  end
end
