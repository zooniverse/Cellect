#!/usr/bin/env ruby

require 'pg'

pg = PG.connect host: 'localhost', port: '5432', dbname: 'cellect', user: 'cellect', password: 'cellect!'

workflows = []
subject_sets = []
subject_sets_workflows = []
subjects = []
user_seen_subjects = []

no_workflows = 10
no_subject_sets = 100
subject_sets_workflows_id = 0

subject_distribution = [10_000] + [40_000] + [90_000] * 2 + [290_000] * 3 + [490_000] * 2 + [990_000]
subject_id_offset = 1
user_seen_subjects_id_offset = 1

1.upto(no_subject_sets).each do |subject_set_id|
  prioritized = rand < 0.5
  subject_sets << [subject_set_id, prioritized]

  subjects_per_set = 10_000 + rand(subject_distribution.sample)

  1.upto(subjects_per_set - 1).each do |subject_id|
    subject_id += subject_id_offset
    
    priority = prioritized ? rand : 0.0
    
    subjects << [subject_id, subject_set_id, subject_id, priority, 0]
  end

  subject_id_offset += subjects_per_set
end

1.upto(no_workflows).each do |workflow_id|
  grouped = rand < 0.5
  prioritized = rand < 0.5
  pairwise = rand < 0.2
  
  workflows << [workflow_id, "Workflow #{ workflow_id }", grouped, prioritized, pairwise]

  sets = if prioritized
           subject_sets.select{ |ss| ss[1] }.sample(1 + rand(3))
         else
           subject_sets.sample(1 + rand(10))
         end

  sets.each do |s|
    subject_sets_workflows << [subject_sets_workflows_id, s[0], workflow_id]
    subject_sets_workflows_id += 1
  end

  subject_ids = sets.flat_map{ |s| subjects.select{ |ss| ss[1] == s[0] }.map{ |s| s[0] } }
  
  users_per_workflow = 10_000 + rand(50_000)
  
  user_seen_distribution = []
  380.times{ user_seen_distribution << [    1,      10] }
  180.times{ user_seen_distribution << [   10,      20] }
  230.times{ user_seen_distribution << [   20,      50] }
   90.times{ user_seen_distribution << [   50,     100] }
  100.times{ user_seen_distribution << [  100,   1_000] }
   17.times{ user_seen_distribution << [1_000,   5_000] }
    3.times{ user_seen_distribution << [5_000, 50_000] }
  
  1.upto(users_per_workflow).each do |user_id|
    user_seen_range = user_seen_distribution.sample
    seen_count = user_seen_range[0] + rand(user_seen_range[1])
    seen_ids = subject_ids.sample(seen_count)
    user_seen_subjects << [user_id + user_seen_subjects_id_offset, "\"{#{ seen_ids.join(",") }}\"", workflow_id, user_id]

  end
  user_seen_subjects_id_offset += users_per_workflow
end

# Open Files
data_dir = '/tmp' 

File.open("#{ data_dir }/workflows.csv", 'w') { |f| f.write(workflows.map{ |l| l.join(',') }.join("\n")) }
File.open("#{ data_dir }/subject_sets.csv", 'w') { |f| f.write(subject_sets.map{ |l| l.join(',') }.join("\n")) }
File.open("#{ data_dir }/subject_sets_workflows.csv", 'w') { |f| f.write(subject_sets_workflows.map{ |l| l.join(',') }.join("\n")) }
File.open("#{ data_dir }/set_member_subjects.csv", 'w') { |f| f.write(subjects.map{ |l| l.join(',') }.join("\n")) }
File.open("#{ data_dir }/user_seen_subjects.csv", 'w') { |f| f.write(user_seen_subjects.map{ |l| l.join(',') }.join("\n")) }

pg.exec <<-SQL
  DROP TABLE IF EXISTS workflows;
  CREATE TABLE workflows (
    "id" SERIAL NOT NULL,
    "name" varchar(255) NOT NULL,
    "grouped" boolean DEFAULT FALSE,
    "prioritized" boolean DEFAULT FALSE,
    "pairwise" boolean DEFAULT FALSE,
    PRIMARY KEY ("id")
  );

  DROP TABLE IF EXISTS subject_sets;
  CREATE TABLE subject_sets (
    "id" SERIAL NOT NULL,
    "prioritized" boolean DEFAULT FALSE,
    PRIMARY KEY ("id")
  );

  DROP TABLE IF EXISTS subject_sets_workflows;
  CREATE TABLE subject_sets_workflows (
    "id" SERIAL NOT NULL,
    "subject_set_id" int DEFAULT NULL,
    "workflow_id" int DEFAULT NULL,
    PRIMARY KEY ("id")
  );

  DROP TABLE IF EXISTS set_member_subjects;
  CREATE TABLE set_member_subjects ( 
    "id" SERIAL NOT NULL,
    "subject_set_id" int DEFAULT NULL,
    "subject_id" int DEFAULT NULL,
    "priority" float NOT NULL DEFAULT 0.0,
    "state" int DEFAULT 0,
    PRIMARY KEY ("id")
  );
  
  DROP TABLE IF EXISTS user_seen_subjects;
  CREATE TABLE user_seen_subjects (
    "id" SERIAL NOT NULL,
    "subject_ids" int[] NOT NULL,
    "workflow_id" int DEFAULT NULL,
    "user_id" int NOT NULL,
    PRIMARY KEY ("id")
  );

  COPY workflows FROM '#{ data_dir }/workflows.csv' DELIMITER ',' NULL AS 'NULL' CSV;
  COPY subject_sets FROM '#{ data_dir }/subject_sets.csv' DELIMITER ',' NULL AS 'NULL' CSV;
  COPY subject_sets_workflows FROM '#{ data_dir }/subject_sets_workflows.csv' DELIMITER ',' NULL AS 'NULL' CSV;
  COPY set_member_subjects FROM '#{ data_dir }/set_member_subjects.csv' DELIMITER ',' NULL AS 'NULL' CSV;
  COPY user_seen_subjects FROM '#{ data_dir }/user_seen_subjects.csv' DELIMITER ',' NULL AS 'NULL' CSV;
  CREATE INDEX idx_user_workflow ON user_seen_subjects(user_id, workflow_id);
  CREATE INDEX idx_subject_set_member_id ON set_member_subjects(subject_set_id);
  CREATE INDEX idx_subject_set_id ON subject_sets_workflows(subject_set_id);
  CREATE INDEX idx_workflow_id ON subject_sets_workflows(workflow_id);
SQL
