require 'spec_helper'

module Cellect
  describe User do
    it_behaves_like 'stateful', :user
    let(:user){ User.new 'test' }
  end
end
