require 'timeout'

module CellectHelper
  def pass_until(&block)
    Timeout::timeout(1) do
      Thread.pass until block.call
    end
  rescue => e
    puts "Timeout waiting for condition #{ block.inspect }"
    raise e
  end

  def pass_until_state_of(obj, is:)
    Timeout::timeout(1) do
      Thread.pass until obj.state == is
    end
  rescue => e
    puts "Timeout waiting for #{ obj.inspect } to be #{ is }"
    raise e
  end
end
