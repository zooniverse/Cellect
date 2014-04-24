require 'spec_helper'

module Cellect
  describe User do
    it_behaves_like 'stateful', :user
    let(:user){ User.new 'test' }
    
    it 'should store seen ids' do
      user.seen.should be_a DiffSet::RandomSet
    end
  end
end
