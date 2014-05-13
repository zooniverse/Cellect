module Cellect
  class API
    class Sets < Grape::API
      get do
        project.sample selector_params
      end
      
      put :add do
        project.add update_params
        nil
      end
      
      put :remove do
        project.remove update_params
        nil
      end
    end
  end
end
