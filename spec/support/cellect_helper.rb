module CellectHelper
  def pass_until(obj, is: is)
    Thread.pass until obj.state == is
  end
end
