require 'timeout'

module CellectHelper
  def pass_until(obj, is:)
    Timeout::timeout(1) do
      puts is
      puts obj.state
      Thread.pass until obj.state == is
    end
  rescue => e
    puts "Timeout waiting for #{ obj.inspect } to be #{ is }"
    raise e
  end
end
