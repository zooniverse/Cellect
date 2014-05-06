require 'socket'
require 'timeout'

module Cellect
  class NodeSet
    include Celluloid
    
    def self.new
      self.supervised_instance ||= supervise    # initialize singleton unless it exists
      supervised_instance.actors.first.name     # ensure the actor isn't dead
    rescue Celluloid::DeadActorError
      self.supervised_instance = supervise      # restart the actor if it's dead
    ensure
      return supervised_instance.actors.first   # always return the instance
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
      after(0.001){ async.initialize_zk } # don't block waiting for ZK to connect
    end
    
    def initialize_zk
      # don't let ZK hang the thread, just retry connection on restart
      Timeout::timeout(5) do
        self.zk = ZK.new zk_url, chroot: '/cellect'
      end
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
      nodes.each do |node|
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
