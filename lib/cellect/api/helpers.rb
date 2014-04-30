module Cellect
  class API
    module Helpers
      def project
        Project[params[:project_id]]
      end
      
      def selector_params
        {
          limit: param_to_int(:limit, default: 5),
          user_id: param_to_int(:user_id),
          group_id: param_to_int(:group_id)
        }
      end
      
      def param_to_int(param, default: nil)
        int = params[param].try :to_i
        params[param] && int && int > 0 ? int : default
      end
    end
  end
end
