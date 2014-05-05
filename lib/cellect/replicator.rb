module Cellect
  class Replicator
    include Celluloid
    
    attr_accessor :zk, :id, :instances
    
    def initialize
      self.zk = ZK.new chroot: '/cellect'
      self.instances = { }
      watch_instances
      setup
    end
    
    protected
    
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
      path = zk.create '/nodes/node', data: "Process #{ Process.pid }", mode: :ephemeral_sequential
      self.id = path.sub /^\/nodes\//, ''
    end
  end
end
