module Cellect
  module Server
    class API
      class Sets < Grape::API
        get do
          workflow.sample selector_params
        end
        
        put :add do
          workflow.add update_params
          nil
        end
        
        put :remove do
          workflow.remove update_params
          nil
        end
      end
    end
  end
end
