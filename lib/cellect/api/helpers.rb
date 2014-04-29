module Cellect
  class API
    module Helpers
      def project
        Project[params[:project_id]]
      end
      
      def limit
        params.fetch(:limit, 5).to_i rescue 5
      end
      
      def group_id
        params[:group_id].try(:to_i) rescue nil
      end
      
      def selector_params
        { limit: limit, group_id: group_id }
      end
    end
  end
end
