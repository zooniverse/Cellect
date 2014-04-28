module Cellect
  class API
    module Helpers
      def project
        # Load correct project type
        Project[params[:project_id]]
      end
      
      def limit
        params.fetch(:limit, 5).to_i rescue 5
      end
    end
  end
end
