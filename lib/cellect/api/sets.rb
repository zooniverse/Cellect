module Cellect
  class API
    class Sets < Grape::API
      get do
        project.sample selector_params
      end
    end
  end
end
