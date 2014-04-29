module ApiHelper
  include Rack::Test::Methods
  
  def app
    Cellect::API.new
  end
end
