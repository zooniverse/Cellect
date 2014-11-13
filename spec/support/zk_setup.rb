zk_dir = File.join CELLECT_ROOT, 'tmp/zookeeper'

CELLECT_ZK_CONFIG = "#{ zk_dir }/zoo.cfg"

unless ENV['ZK_URL']
  `rm -rf #{ zk_dir }; mkdir -p #{ zk_dir }`

  File.open(CELLECT_ZK_CONFIG, 'w') do |out|
    out.puts <<-TEXT
      tickTime=2000
      initLimit=10
      syncLimit=5
      dataDir=#{ zk_dir }
      clientPort=21811
      forceSync=no
      snapCount=1000000
    TEXT
  end


  if `echo ruok | nc 127.0.0.1 21811`.chomp == 'imok'
    pid = `ps aux | grep -e 'Cellect[\/]tmp[\/]zookeeper'`.split[1]
    puts "Killing rogue zookeeper process: #{ pid }..."
    `kill -s TERM #{ pid }`
    sleep 1
  end

  `zkServer start #{ CELLECT_ZK_CONFIG } > /dev/null 2>&1`
  ENV['ZK_URL'] ||= 'localhost:21811'
end
