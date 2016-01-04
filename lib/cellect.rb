require 'celluloid'
require 'cellect/version'
require 'attention'

module Cellect
end

Attention.options[:namespace] = 'cellect'
Attention.options[:redis_url] = ENV['REDIS_URL'] if ENV['REDIS_URL']
Attention.options[:ttl] = 20
