require 'attention'

Attention.options[:namespace] = ENV.fetch('ATTENTION_NAMESPACE', 'cellect')
Attention.options[:redis_url] ||= ENV['REDIS_URL'] if ENV['REDIS_URL']
Attention.options[:ttl] = ENV.fetch('ATTENTION_TTL', 20).to_i
