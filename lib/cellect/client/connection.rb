require 'http'

module Cellect
  module Client
    class Connection
      include Celluloid
      include Celluloid::IO
      
      def reload_workflow(id)
        broadcast :post, "/workflows/#{ id }/reload"
      end
      
      def delete_workflow(id)
        broadcast :delete, "/workflows/#{ id }"
      end
      
      def add_subject(id, workflow_id: workflow_id, group_id: nil, priority: nil)
        broadcast :put, "/workflows/#{ workflow_id }/add", querystring(subject_id: id, group_id: group_id, priority: priority)
      end
      
      def remove_subject(id, workflow_id: workflow_id, group_id: nil)
        broadcast :put, "/workflows/#{ workflow_id }/remove", querystring(subject_id: id, group_id: group_id)
      end
      
      def load_user(id, host: host, workflow_id: workflow_id)
        send_http host, :post, "/workflows/#{ workflow_id }/users/#{ id }/load"
      end
      
      def add_seen(id, user_id: user_id, host: host, workflow_id: workflow_id)
        send_http host, :put, "/workflows/#{ workflow_id }/users/#{ user_id }/add_seen", querystring(subject_id: id)
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
    end
  end
end
