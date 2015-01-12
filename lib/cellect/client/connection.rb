require 'http'
require 'multi_json'

module Cellect
  module Client
    class CellectServerError < StandardError; end
    class Connection
      include Celluloid
      include Celluloid::IO
      
      def reload_workflow(id)
        broadcast :post, "/workflows/#{ id }/reload"
      end
      
      def delete_workflow(id)
        broadcast :delete, "/workflows/#{ id }"
      end
      
      def add_subject(id, workflow_id: nil, group_id: nil, priority: nil)
        broadcast :put, "/workflows/#{ workflow_id }/add", querystring(subject_id: id, group_id: group_id, priority: priority)
      end
      
      def remove_subject(id, workflow_id: nil, group_id: nil)
        broadcast :put, "/workflows/#{ workflow_id }/remove", querystring(subject_id: id, group_id: group_id)
      end
      
      def load_user(user_id: nil, host: nil, workflow_id: nil)
        send_http host, :post, "/workflows/#{ workflow_id }/users/#{ user_id }/load"
      end
      
      def add_seen(subject_id: nil, user_id: nil, host: nil, workflow_id: nil)
        send_http host, :put, "/workflows/#{ workflow_id }/users/#{ user_id }/add_seen", querystring(subject_id: subject_id)
      end
      
      def get_subjects(user_id: nil, host: nil, workflow_id: nil, limit: nil, group_id: nil)
        response = send_http host, :get, "/workflows/#{ workflow_id }", querystring(user_id: user_id, group_id: group_id, limit: limit)
        ensure_valid_response response
        MultiJson.load response.body
      end
      
      protected
      
      def broadcast(action, path, query = '')
        Cellect::Client.node_set.nodes.each_pair do |node, host|
          send_http host, action, path, query
        end
      end
      
      def send_http(host, action, path, query = '')
        params = { host: host, path: path }
        params[:query] = query if query && !query.empty?
        uri = URI::HTTP.build params
        HTTP.send action, uri.to_s, socket_class: Celluloid::IO::TCPSocket
      end
      
      def querystring(hash = { })
        [].tap do |list|
          hash.each_pair do |key, value|
            next unless value
            list << "#{ key }=#{ value }"
          end
        end.join('&')
      end
      
      def ensure_valid_response(response)
        unless response.code == 200
          raise CellectServerError, "Server Responded #{ response.code }"
        end
      end
    end
  end
end
