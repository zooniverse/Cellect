require 'http'

module Cellect
  module Client
    class Connection
      include Celluloid
      include Celluloid::IO
      
      def reload_project(id)
        broadcast :post, "/projects/#{ id }/reload"
      end
      
      def delete_project(id)
        broadcast :delete, "/projects/#{ id }"
      end
      
      def add_subject(id, project_id: project_id, group_id: nil, priority: nil)
        broadcast :put, "/projects/#{ project_id }/add", querystring(subject_id: id, group_id: group_id, priority: priority)
      end
      
      def remove_subject(id, project_id: project_id, group_id: nil)
        broadcast :put, "/projects/#{ project_id }/remove", querystring(subject_id: id, group_id: group_id)
      end
      
      def load_user(id, host: host, project_id: project_id)
        send_http host, :post, "/projects/#{ project_id }/users/#{ id }/load"
      end
      
      def add_seen(id, user_id: user_id, host: host, project_id: project_id)
        send_http host, :put, "/projects/#{ project_id }/users/#{ user_id }/add_seen", querystring(subject_id: id)
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
