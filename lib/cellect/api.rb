require 'grape'

module Cellect
  class API < Grape::API
    format :json
    
    require 'cellect/api/helpers'
    require 'cellect/api/sets'
    
    resources :projects do
      segment '/:project_id' do
        helpers Helpers
        mount Sets
      end
    end
  end
end
