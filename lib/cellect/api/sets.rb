module Cellect
  class API
    class Sets < Grape::API
      get do
        project.sample selector_params
      end
      
      get :status do
        # information like size, ops/second, etc
      end
      
      get :subtract do
        # user diff
      end
      
      put :add do
        # add or update element
      end
      
      put :remove do
        # remove element
      end
    end
  end
end
