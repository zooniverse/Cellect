module Cellect
  class API
    class Sets < Grape::API
      get do
        project.sample selector_params
      end
      
      put :add do
        project.add update_params
        replicate update_params
        nil
      end
      
      put :remove do
        project.remove update_params
        replicate update_params
        nil
      end
      
      put :add_seen do
        user_id, subject_id = seen_params.values_at :user_id, :subject_id
        if user_id && user_id > 0 && subject_id && subject_id > 0
          project.async.add_seen_for user_id, subject_id
        end
        
        nil
      end
    end
  end
end
