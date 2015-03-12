module Cellect
  module Server
    class API
      class Users < Grape::API
        resources :users do
          segment '/:user_id' do
            # PUT /workflows/:workflow_id/users/:user_id/add_seen
            # 
            # Adds a subject to a user's seen set for a workflow
            # Accepts params
            #   subject_id: integer, required
            put :add_seen do
              user_id = param_to_int :user_id
              subject_id = param_to_int :subject_id
              
              if user_id && user_id > 0 && subject_id && subject_id > 0
                workflow.async.add_seen_for user_id, subject_id
              end
              
              nil
            end
            
            # POST /workflows/:workflow_id/users/:user_id/load
            # 
            # Preloads a user for a workflow
            post :load do
              user_id = param_to_int :user_id
              
              if user_id && user_id > 0
                workflow.async.user user_id
              end
              
              nil
            end
          end
        end
      end
    end
  end
end
