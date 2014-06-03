require 'pg'
require 'connection_pool'

module Cellect
  module Server
    module Adapters
      class Postgres < Default
        def initialize
          @pg ||= ConnectionPool.new(size: ENV.fetch('PG_POOL_SIZE', 25).to_i) do
            PG.connect connection_options
          end
        end
        
        def workflow_list
          with_pg do |pg|
            pg.exec('select * from workflows').collect do |row|
              {
                'id' => row['id'].to_i,
                'name' => row['id'],
                'prioritized' => row['prioritized'] == 't',
                'pairwise' => row['pairwise'] == 't',
                'grouped' => row['grouped'] == 't'
              }
            end
          end
        end
        
        def load_data_for(workflow_name)
          with_pg do |pg|
            pg.exec("select id, priority, group_id from workflow_#{ workflow_name }_subjects").collect do |row|
              {
                'id' => row['id'].to_i,
                'priority' => row['priority'].to_f,
                'group_id' => row['group_id'].to_i
              }
            end
          end
        end
        
        def load_user(workflow_name, id)
          with_pg do |pg|
            pg.exec("select subject_id from workflow_#{ workflow_name }_classifications where user_id=#{ id }").collect do |row|
              row['subject_id'].to_i
            end
          end
        end
        
        def with_pg
          @pg.with{ |pg| yield pg }
        end
        
        def connection_options
          {
            host: ENV.fetch('PG_HOST', '127.0.0.1'),
            port: ENV.fetch('PG_PORT', '5432'),
            dbname: ENV.fetch('PG_DB', 'cellect'),
            user: ENV.fetch('PG_USER', 'cellect'),
            password: ENV.fetch('PG_PASS', '')
          }
        end
      end
    end
  end
end
