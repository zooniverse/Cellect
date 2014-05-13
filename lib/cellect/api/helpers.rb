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
      
      def update_params
        {
          subject_id: param_to_int(:subject_id),
          group_id: param_to_int(:group_id),
          priority: param_to_float(:priority)
        }
      end
      
      def seen_params
        {
          user_id: param_to_int(:user_id),
          subject_id: param_to_int(:subject_id)
        }
      end
      
      def param_to_int(param, default: nil)
        _param_to param, :to_i, default
      end
      
      def param_to_float(param, default: nil)
        _param_to param, :to_f, default
      end
      
      def _param_to(param, conversion, default)
        val = params[param].try conversion
        params[param] && val && val > 0 ? val : default
      end
      
      def replicate(query = { })
        return if params[:replicated]
        query_string = to_query query.merge(replicated: true)
        Cellect.replicator.replicate request.request_method.downcase, request.path, query_string
      end
      
      def to_query(hash)
        hash.select{ |k, v| v }.collect{ |k, v| "#{ k }=#{ v }" }.join '&'
      end
    end
  end
end
