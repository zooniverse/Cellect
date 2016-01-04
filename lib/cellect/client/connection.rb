require 'http'
require 'multi_json'

module Cellect
  module Client
    class CellectServerError < StandardError; end
    class Connection
      class << self
        attr_accessor :timeout
      end

      @timeout = 5

      # Reload the data for a workflow on all servers
      def reload_workflow(id)
        broadcast :post, "/workflows/#{ id }/reload"
      end

      # Remove the workflow from all servers
      def delete_workflow(id)
        broadcast :delete, "/workflows/#{ id }"
      end

      # Adds or updates a subject on all servers
      def add_subject(id, workflow_id:, group_id: nil, priority: nil)
        broadcast :put, "/workflows/#{ workflow_id }/add", querystring(subject_id: id, group_id: group_id, priority: priority)
      end

      # Removes a subject on all servers
      def remove_subject(id, workflow_id:, group_id: nil)
        broadcast :put, "/workflows/#{ workflow_id }/remove", querystring(subject_id: id, group_id: group_id)
      end

      # Preload a user on a server
      def load_user(user_id:, host:, workflow_id:)
        send_http host, :post, "/workflows/#{ workflow_id }/users/#{ user_id }/load"
      end

      # Adds a subject to a users seen set
      def add_seen(subject_id:, user_id:, host:, workflow_id:)
        send_http host, :put, "/workflows/#{ workflow_id }/users/#{ user_id }/add_seen", querystring(subject_id: subject_id)
      end

      # Gets unseen subjects for a user
      def get_subjects(user_id:, host:, workflow_id:, limit: nil, group_id: nil)
        response = send_http host, :get, "/workflows/#{ workflow_id }", querystring(user_id: user_id, group_id: group_id, limit: limit)
        ensure_valid_response response
        MultiJson.load response.body
      end

      protected

      # Broadcast by iterating over each server
      def broadcast(action, path, query = '')
        Cellect::Client.node_set.nodes.each do |node|
          send_http node['ip'], action, path, query
        end
      end

      # Makes an API call
      def send_http(host, action, path, query = '')
        params = { host: host, path: path }
        params[:query] = query if query && !query.empty?
        uri = URI::HTTP.build params
        with_timeout.send action, uri.to_s
      end

      def with_timeout
        HTTP.timeout :global, connect: self.class.timeout
      end

      # Builds a querystring from a hash
      def querystring(hash = { })
        [].tap do |list|
          hash.each_pair do |key, value|
            next unless value
            list << "#{ key }=#{ value }"
          end
        end.join('&')
      end

      # Ensure the API response was OK
      def ensure_valid_response(response)
        unless response.code == 200
          raise CellectServerError, "Server Responded #{ response.code }"
        end
      end
    end
  end
end
