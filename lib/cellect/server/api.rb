require 'grape'

module Cellect
  module Server
    class API < Grape::API
      format :json
      
      require 'cellect/server/api/helpers'
      require 'cellect/server/api/sets'
      require 'cellect/server/api/users'
      
      get :stats do
        usage = ->(keyword) do
          `ps axo #{ keyword }`.chomp.split("\n")[1..-1].collect(&:to_f).inject :+
        end
        
        {
          memory: usage.call('%mem'),
          cpu: usage.call('%cpu')
        }
      end
      
      resources :workflows do
        get do
          Cellect::Server.adapter.workflow_list
        end
        
        segment '/:workflow_id' do
          helpers Helpers
          mount Sets
          mount Users
          
          get :status do
            workflow.status
          end
          
          post :reload do
            workflow.async.load_data
          end
          
          delete do
            # delete a workflow (maybe?)
          end
        end
      end
    end
  end
end
