module Cellect
  module Server
    module Adapters
      class Default
        # Return a list of workflows to load in the form:
        #   [{
        #     'id' => 123,
        #     'name' => 'foo',
        #     'prioritized' => false,
        #     'pairwise' => false,
        #     'grouped' => false
        #   }, ...]
        def workflow_list
          raise NotImplementedError
        end
        
        # Load the data for a workflow, this method:
        #   Accepts a workflow
        #   Returns an array of hashes in the form:
        #   {
        #     'id' => 123,
        #     'priority' => 0.123,
        #     'group_id' => 456
        #   }
        def load_data_for(workflow_name)
          raise NotImplementedError
        end
        
        # Load seen ids for a user, this method:
        #   Accepts a workflow_name, and a user id
        #   Returns an array in the form:
        #   [1, 2, 3]
        def load_user(workflow_name, id)
          raise NotImplementedError
        end
        
        def load_workflows
          workflow_list.each{ |workflow_info| load_workflow workflow_info }
        end
        
        def load_workflow(args)
          info = if args.is_a?(Hash)
            args
          elsif args.is_a?(String)
            workflow_list.select{ |h| h['name'] == args }.first
          else
            raise ArgumentError
          end
          
          workflow_for info
        end
        
        def workflow_for(opts = { })
          workflow_klass = opts.fetch('grouped', false) ? GroupedWorkflow : Workflow
          workflow_klass[opts['name'], pairwise: opts['pairwise'], prioritized: opts['prioritized']]
        end
      end
    end
  end
end
