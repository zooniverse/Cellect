module Cellect
  module Client 
    class NoZkUrlError < StandardError; end;

    class CellectRailtie < Rails::Railtie
      initializer "cellect.connecto_to_zookeeper" do
        config = YAML.load File.read Rails.root.join 'config/cellect.yml'
        config = config[Rails.env].symbolize_keys

        unless config.has_key? :zk_url
          raise NoZkUrlError.new "No Zookeeper URL provided for #{Rails.env} environment"
        end

        Client.node_set config[:zk_url]
        Client.connection = Connection.pool size: config[:pool_size] || 100
      end
    end
  end
end
