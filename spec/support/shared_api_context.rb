shared_context 'API' do
  include Rack::Test::Methods
  
  def app
    $app ||= Cellect::API.new
  end
  
  def json
    Oj.strict_load last_response.body
  end
end
