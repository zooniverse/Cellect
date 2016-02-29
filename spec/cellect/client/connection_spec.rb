require 'spec_helper'

module Cellect::Client
  describe Connection do
    let(:connection){ Cellect::Client.connection }

    before(:each) do
      allow(Cellect::Client.node_set).to receive(:nodes).and_return [
        { 'id' => '1', 'ip' => '1.2.3.4' },
        { 'id' => '2', 'ip' => '5.6.7.8' }
      ]
    end

    def should_send(action:, url:, to:)
      send_double = double
      expect(HTTP).to receive(:timeout).with(:global, connect: Connection.timeout).and_return send_double
      expect(send_double).to receive(:send).with(action, "http://#{ to }/#{ url }").and_return(HTTP::Response.new(200, nil, nil, "{ \"this response\": \"intentionally blank\" }"))
    end

    def should_broadcast(action:, url:)
      ['1.2.3.4', '5.6.7.8'].each{ |ip| should_send action: action, url: url, to: ip }
    end

    it 'should reload workflows' do
      should_broadcast action: :post, url: 'workflows/random/reload'
      connection.reload_workflow 'random'
    end

    it 'should delete workflows' do
      should_broadcast action: :delete, url: 'workflows/random'
      connection.delete_workflow 'random'
    end

    it 'should add subjects' do
      should_broadcast action: :put, url: 'workflows/random/add?subject_id=123'
      connection.add_subject 123, workflow_id: 'random'
    end

    it 'should add grouped subjects' do
      should_broadcast action: :put, url: 'workflows/random/add?subject_id=123&group_id=321'
      connection.add_subject 123, workflow_id: 'random', group_id: 321
    end

    it 'should add prioritized grouped subjects' do
      should_broadcast action: :put, url: 'workflows/random/add?subject_id=123&group_id=321&priority=0.123'
      connection.add_subject 123, workflow_id: 'random', group_id: 321, priority: 0.123
    end

    it 'should remove subjects' do
      should_broadcast action: :put, url: 'workflows/random/remove?subject_id=123'
      connection.remove_subject 123, workflow_id: 'random'
    end

    it 'should remove grouped subjects' do
      should_broadcast action: :put, url: 'workflows/random/remove?subject_id=123&group_id=321'
      connection.remove_subject 123, workflow_id: 'random', group_id: 321
    end

    it 'should load users' do
      should_send action: :post, url: 'workflows/random/users/123/load', to: '1.2.3.4'
      connection.load_user user_id: 123, host: '1.2.3.4', workflow_id: 'random'
    end

    it 'should add seen subjects' do
      should_send action: :put, url: 'workflows/random/users/123/add_seen?subject_id=456', to: '1.2.3.4'
      connection.add_seen subject_id: 456, host: '1.2.3.4', user_id: 123, workflow_id: 'random'
    end

    it 'should get subjects' do
      should_send action: :get, url: 'workflows/random?user_id=1', to: '1.2.3.4'
      connection.get_subjects host: '1.2.3.4', workflow_id: 'random', user_id: 1
    end

    it 'should get grouped subjects' do
      should_send action: :get, url: 'workflows/random?user_id=1&group_id=1&limit=10', to: '1.2.3.4'
      connection.get_subjects host: '1.2.3.4', workflow_id: 'random', user_id: 1, limit: 10, group_id: 1
    end

    context 'getting subjects' do
      def get_subjects
        connection.get_subjects host: '1.2.3.4', workflow_id: 'random', user_id: 1, limit: 10, group_id: 1
      end

      it 'should return subjects as an array' do
        response = HTTP::Response.new 200, '1.1', nil, '[1, 2, 3, 4, 5]'
        send_double = double
        expect(HTTP).to receive(:timeout).with(:global, connect: Connection.timeout).and_return send_double
        expect(send_double).to receive(:send).and_return response
        expect(get_subjects).to eq [1, 2, 3, 4, 5]
      end

      it 'should raise an error for unexpected responses' do
        response = HTTP::Response.new 404, '1.1', nil, ''
        send_double = double
        expect(HTTP).to receive(:timeout).with(:global, connect: Connection.timeout).and_return send_double
        expect(send_double).to receive(:send).and_return response
        expect{ get_subjects }.to raise_error CellectServerError, 'Server Responded 404'
      end
    end
  end
end
