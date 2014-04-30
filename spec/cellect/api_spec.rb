require 'spec_helper'

module Cellect
  describe API do
    include ApiHelper
    
    before(:each) do
      Cellect.adapter.load_project 'random'
    end
    
    it 'should do something' do
      get '/projects/random'
      last_response.status.should == 200
    end
  end
end
