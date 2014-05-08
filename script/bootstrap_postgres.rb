#!/usr/bin/env ruby

require 'pg'

data_dir = File.expand_path File.join(File.dirname(__FILE__), '../data')
pg = PG.connect host: '127.0.0.1', port: '5433', dbname: 'cellect', user: 'cellect', password: 'ce11ect!'

pg.exec <<-SQL
  DROP TABLE IF EXISTS projects;
  CREATE TABLE projects (
    "id" SERIAL NOT NULL,
    "name" varchar(255) NOT NULL,
    "grouped" boolean DEFAULT FALSE,
    "prioritized" boolean DEFAULT FALSE,
    "pairwise" boolean DEFAULT FALSE,
    PRIMARY KEY ("id")
  );
SQL

projects = 10
subject_distribution = [10_000] + [40_000] + [90_000] * 2 + [290_000] * 3 + [490_000] * 2 + [990_000]

1.upto(projects).each do |project_id|
  grouped = rand < 0.5
  prioritized = rand < 0.5
  pairwise = rand < 0.2
  
  pg.exec "INSERT INTO projects VALUES(#{ project_id }, 'Project #{ project_id }', #{ grouped }, #{ prioritized }, #{ pairwise })"
  
  groups_per_project = 3 + rand(50)
  subjects_per_project = 10_000 + rand(subject_distribution.sample)
  users_per_project = 10_000 + rand(50_000)
  
  user_seen_distribution = []
  380.times{ user_seen_distribution << [    1,      10] }
  180.times{ user_seen_distribution << [   10,      20] }
  230.times{ user_seen_distribution << [   20,      50] }
   90.times{ user_seen_distribution << [   50,     100] }
  100.times{ user_seen_distribution << [  100,   1_000] }
   17.times{ user_seen_distribution << [1_000,   5_000] }
    3.times{ user_seen_distribution << [5_000, 50_000] }
  
  subjects = { }
  
  1.upto(users_per_project).each do |user_id|
    user_seen_range = user_seen_distribution.sample
    seen_count = user_seen_range[0] + rand(user_seen_range[1])
    seen_ids = seen_count.times.collect{ rand(subjects_per_project) }
    
    seen_ids.each do |subject_id|
      subjects[subject_id] ||= []
      subjects[subject_id] << user_id
    end
  end
  
  subject_table = "project_#{ project_id }_subjects"
  classification_table = "project_#{ project_id }_classifications"
  
  pg.exec <<-SQL
    DROP TABLE IF EXISTS #{ subject_table };
    CREATE TABLE #{ subject_table } (
      "id" SERIAL NOT NULL,
      "group_id" int DEFAULT NULL,
      "user_ids" int[] NOT NULL DEFAULT '{}',
      "priority" float NOT NULL DEFAULT 0.0,
      "state" varchar(255) NOT NULL DEFAULT 'active',
      PRIMARY KEY ("id")
    );
    
    DROP TABLE IF EXISTS #{ classification_table };
    CREATE TABLE #{ classification_table } (
      "id" SERIAL NOT NULL,
      "subject_id" int NOT NULL,
      "group_id" int DEFAULT NULL,
      "user_id" int NOT NULL,
      PRIMARY KEY ("id")
    );
  SQL
  
  subject_data = File.open "#{ data_dir }/#{ subject_table }.csv", 'w'
  classification_data = File.open "#{ data_dir }/#{ classification_table }.csv", 'w'
  classification_id = 0
  
  1.upto(subjects_per_project - 1).each do |subject_id|
    if subject_id % 100 == 0
      progress = (100 * subject_id / subjects_per_project.to_f).round
      puts "[#{ project_id }:#{ projects }] #{ subject_id } / #{ subjects_per_project } (#{ progress }%)"
    end
    
    group_id = grouped ? 1 + rand(groups_per_project) : 'NULL'
    priority = prioritized ? rand : 0.0
    user_ids = subjects.fetch(subject_id, [])
    user_id_a = "\"{#{ user_ids.join(',') }}\""
    
    subject_data.puts [subject_id, group_id, user_id_a, priority, '"active"'].join(',')
    rows = user_ids.collect do |user_id|
      classification_id += 1
      [classification_id, subject_id, group_id, user_id].join(',')
    end
    classification_data.puts(rows.join("\n")) unless rows.empty?
  end
  
  subject_data.close
  classification_data.close
  puts 'inserting records...'
  
  pg.exec <<-SQL
    COPY #{ subject_table } FROM '/cellect_data/#{ subject_table }.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    COPY #{ classification_table } FROM '/cellect_data/#{ classification_table }.csv' DELIMITER ',' NULL AS 'NULL' CSV;
    CREATE INDEX ON #{ classification_table } USING btree(subject_id ASC, user_id ASC NULLS LAST);
    CREATE INDEX ON #{ subject_table } USING btree(id ASC, state ASC NULLS LAST);
  SQL
end
