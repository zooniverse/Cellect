module Cellect
  class API
    class Sets < Grape::API
      get do
        { route: 'index' }
      end
    end
  end
end
