require 'diff_set'
require 'celluloid'
require 'celluloid/autostart'

module DiffSet
  require 'diff_set/pairwise_random_set'
  require 'diff_set/pairwise_priority_set'
end

module Cellect
  require 'cellect/stateful'
  require 'cellect/project'
  require 'cellect/grouped_project'
  require 'cellect/user'
end
