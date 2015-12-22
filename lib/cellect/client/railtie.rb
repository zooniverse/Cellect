module Cellect
  module Client
    class ConfigurationError < StandardError; end;

    # Allow YAML configuration from config/cellect.yml
    # 
    # development:
    #   zk_url: localhost:2181
    #   pool_size: 50
    class CellectRailtie < Rails::Railtie
      initializer 'cellect.connect_to_zookeeper' do
        ensure_config_file
        config = YAML.load_file config_file
        ensure_config_environment config
        config = config[Rails.env].symbolize_keys
        ensure_config_url config
        connect_zookeeper config if load_zookeeper
      end

      private

      def config_file
        Rails.root.join 'config/cellect.yml'
      end

      def ensure_config_file
        return if File.exists?(config_file)
        raise ConfigurationError.new 'No configuration file found. Create config/cellect.yml first'
      end

      def ensure_config_environment(yaml)
        return if yaml[Rails.env].is_a?(Hash)
        raise ConfigurationError.new "No configuration for #{ Rails.env } found"
      end

      def ensure_config_url(hash)
        return if hash[:zk_url].present?
        raise ConfigurationError.new "No Zookeeper URL provided for #{ Rails.env } environment"
      end

      def connect_zookeeper(config)
        Client.node_set config[:zk_url]
        Client.connection = Connection.pool size: config.fetch(:pool_size, 100)
      end

      def load_zookeeper
        !Client.mock_zookeeper?
      end
    end
  end
end
