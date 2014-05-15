module Cellect
  module Server
    class API
      class Users < Grape::API
        resources :users do
          segment '/:user_id' do
            put :add_seen do
              user_id = param_to_int :user_id
              subject_id = param_to_int :subject_id
              
              if user_id && user_id > 0 && subject_id && subject_id > 0
                project.async.add_seen_for user_id, subject_id
              end
              
              nil
            end
            
            post :load do
              user_id = param_to_int :user_id
              
              if user_id && user_id > 0
                project.async.user user_id
              end
              
              nil
            end
          end
        end
      end
    end
  end
end
