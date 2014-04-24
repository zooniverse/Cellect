require 'spec_helper'

module Cellect
  describe Project do
    it_behaves_like 'stateful', :project
    let(:project){ Project.new 'test' }
  end
end
