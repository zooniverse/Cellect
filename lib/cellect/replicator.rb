require 'socket'
require 'celluloid/io'
require 'http'
require 'uri'

module Cellect
  class Replicator
    include Celluloid
    include Celluloid::IO
    
    attr_accessor :zk, :id, :instances
    
    def initialize
      self.instances = { }
      async.initialize_zk
    end
    
    def replicate(method, path, query = '')
      instances.each_pair do |node_id, host|
        async._replicate host, method, path, query
      end
    end
    
    protected
    
    def initialize_zk
      self.zk = ZK.new zk_url, chroot: '/cellect'
      watch_instances
      setup
    end
    
    def _replicate(host, method, path, query)
      uri = URI::HTTP.build host: host, path: path, query: query
      HTTP.send method, uri.to_s, socket_class: Celluloid::IO::TCPSocket
    end
    
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
