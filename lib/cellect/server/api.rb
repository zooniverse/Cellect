require 'grape'

module Cellect
  module Server
    class API < Grape::API
      format :json
      
      require 'cellect/server/api/helpers'
      require 'cellect/server/api/sets'
      require 'cellect/server/api/users'
      
      # GET /stats
      # 
      # Provides system load information
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
        
        # GET /workflows
        # 
        # Returns a list of available workflows
        get do
          Cellect::Server.adapter.workflow_list
        end
        
        segment '/:workflow_id' do
          helpers Helpers
          mount Sets
          mount Users
          
          # GET /workflows/:workflow_id/status
          # 
          # Returns the workflow's status
          get :status do
            workflow.status
          end
          
          # POST /workflows/:workflow_id/reload
          # 
          # Reloads the workflow from the adapter
          post :reload do
            workflow.async.load_data
          end
          
          # DELETE /workflows/:workflow_id
          # 
          # Not implemented
          delete do
            # delete a workflow (maybe?)
          end
        end
      end
    end
  end
end
