module Cellect
  module Server
    class API
      module Helpers
        def workflow
          @workflow ||= Workflow[params[:workflow_id]]
        end

        def four_oh_four
          error! 'Not Found', 404
        end

        def bad_request
          error! 'Bad Request', 400
        end

        def validate_param(hash, key, expect: nil)
          hash[key] && hash[key].is_a?(expect)
        end

        def valid_subject_id_update?
          validate_param update_params, :subject_id, expect: Fixnum
        end

        def valid_group_id_update?
          return true unless workflow.grouped?
          validate_param update_params, :group_id, expect: Fixnum
        end

        def valid_priority_update?
          return true unless workflow.prioritized?
          validate_param update_params, :priority, expect: Numeric
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
