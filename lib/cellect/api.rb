require 'grape'

module Cellect
  class API < Grape::API
    format :json
    
    require 'cellect/api/helpers'
    require 'cellect/api/sets'
    
    get '/replication_status' do
      {
        connected: Cellect.replicator.ready?,
        node_id: Cellect.replicator.id,
        other_nodes: Cellect.replicator.nodes
      }
    end
    
    resources :projects do
      segment '/:project_id' do
        helpers Helpers
        mount Sets
        
        get :status do
          project.status
        end
        
        post :reload do
          replicate
          Cellect.adapter.load_project project.name
        end
        
        delete do
          # delete a project (maybe?)
        end
      end
    end
  end
end
