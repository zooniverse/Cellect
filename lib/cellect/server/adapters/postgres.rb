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

        def workflow_list(*names)
          with_pg do |pg|
            statement = 'SELECT * FROM workflows'
            statement += case names.length
                         when 0
                           ""
                         when 1
                           "WHERE \"workflows\".\"id\" = #{ names.first }"
                         else
                           "WHERE \"workflows\".\"id\" IN (#{ names.join(',') })"
                         end
            pg.exec(statement).collect do |row|
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
            statement = <<-SQL
              SELECT sms.id as id, sms.priority as priority, sms.subject_set_id as group_id
              FROM workflows w
              JOIN subject_sets ss ON (ss.workflow_id = w.id)
              JOIN set_member_subjects sms ON (sms.subject_set_id = ss.id)
              WHERE w.id = #{ workflow_name }
            SQL
            pg.exec(statement).collect do |row|
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
            statement = <<-SQL
              SELECT set_member_subject_ids FROM user_seen_subjects
              WHERE user_id = #{ id } AND workflow_id = #{ workflow_name }
            SQL
            pg.exec(statement).collect do |row|
              row['subject_ids'].map(&:to_i)
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
