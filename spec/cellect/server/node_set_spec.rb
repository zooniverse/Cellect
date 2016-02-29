require 'spec_helper'

module Cellect::Server
  describe NodeSet do
    describe '#setup' do
      it 'should activate this node' do
        expect(Attention).to receive :activate
        subject
      end

      it 'should register this node' do
        expect(subject.instance).to be_a Attention::Instance
      end
    end
  end
end
