module Cellect
  module Server
    class API
      class Sets < Grape::API
        # GET /workflows/:workflow_id
        # 
        # Returns a sample from the specified workflow
        # Accepts params
        #   limit: integer, default 5
        #   user_id: integer, optional
        #   group_id: integer, optional
        get do
          return four_oh_four unless workflow
          workflow.sample(selector_params)
        end

        # PUT /workflows/:workflow_id/add
        # 
        # Adds a subject to a workflow or updates the priority
        # Accepts params
        #   subject_id: integer
        #   group_id: integer, required if grouped
        #   priority: float, required if prioritized
        put :add do
          return four_oh_four unless workflow
          workflow.add(update_params)
          nil
        end

        # PUT /workflows/:workflow_id/remove
        # 
        # Removes a subject from a workflow
        # Accepts params
        #   subject_id: integer
        #   group_id: integer, required if grouped
        put :remove do
          return four_oh_four unless workflow
          workflow.remove(update_params)
          nil
        end
      end
    end
  end
end
