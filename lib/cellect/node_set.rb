require 'socket'

module Cellect
  class NodeSet
    include Celluloid
    
    def self.new
      self.supervised_instance ||= supervise
      supervised_instance.actors.first.name
    rescue Celluloid::DeadActorError
      self.supervised_instance = supervise
    ensure
      node_set = supervised_instance.actors.first
      node_set.async.initialize_zk unless node_set.zk && node_set.zk.connected?
      return node_set
    end
    
    class << self
      attr_accessor :supervised_instance, :state, :id, :nodes
      alias_method :instance, :new
    end
    
    attr_accessor :zk
    
    def self.ready?
      state == :ready
    end
    
    def initialize
      self.class.state = :initializing
      self.class.nodes = { }
    end
    
    def initialize_zk
      self.zk = ZK.new zk_url, chroot: '/cellect'
      watch_nodes
      setup
      self.class.state = :ready
    end
    
    protected
    
    def zk_url
      ENV.fetch 'ZK_URL', 'localhost:2181'
    end
    
    def nodes_changed(nodes)
      self.class.nodes = { }
      self.class.nodes.each do |node|
        next if node == self.class.id
        self.class.nodes[node] = zk.get("/nodes/#{ node }").first
      end
    end
    
    def setup
      zk.mkdir_p '/nodes'
      zk.children '/nodes', watch: true
      ip = Socket.ip_address_list.find{ |address| address.ipv4? && !address.ipv4_loopback? }.ip_address
      path = zk.create '/nodes/node', data: ip, mode: :ephemeral_sequential
      self.class.id = path.sub /^\/nodes\//, ''
    end
    
    def watch_nodes
      zk.register('/nodes') do |event|
        nodes_changed zk.children('/nodes', watch: true)
      end
    end
  end
end
