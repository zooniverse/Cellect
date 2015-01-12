require 'timeout'

module CellectHelper
  def pass_until(obj, is: nil)
    Timeout::timeout(1) do
      Thread.pass until obj.state == is
    end
  rescue => e
    puts "Timeout waiting for #{ obj.inspect } to be #{ is }"
    raise e
  end
end
