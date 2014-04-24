require 'spec_helper'

module Cellect
  describe GroupedProject do
    it_behaves_like 'stateful', :project
    let(:project){ GroupedProject.new 'test' }
  end
end
