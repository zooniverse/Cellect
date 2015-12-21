module Cellect
  module Server
    class API
      module Helpers
        def workflow
          @workflow ||= Workflow[params[:workflow_id]]
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

        def param_to_int(param, default: nil)
          _param_to param, :to_i, default
        end

        def param_to_float(param, default: nil)
          _param_to param, :to_f, default
        end

        def _param_to(param, conversion, default)
          val = params[param] && params[param].send(conversion)
          params[param] && val && val > 0 ? val : default
        end
      end
    end
  end
end
