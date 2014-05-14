require 'grape'

module Cellect
  class API < Grape::API
    format :json
    
    require 'cellect/api/helpers'
    require 'cellect/api/sets'
    require 'cellect/api/users'
    
    get :stats do
      usage = ->(keyword) do
        `ps axo #{ keyword }`.chomp.split("\n")[1..-1].collect(&:to_f).inject :+
      end
      
      {
        memory: usage.call('%mem'),
        cpu: usage.call('%cpu')
      }
    end
    
    resources :projects do
      get do
        Cellect.adapter.project_list
      end
      
      segment '/:project_id' do
        helpers Helpers
        mount Sets
        mount Users
        
        get :status do
          project.status
        end
        
        post :reload do
          project.async.load_data
        end
        
        delete do
          # delete a project (maybe?)
        end
      end
    end
  end
end
