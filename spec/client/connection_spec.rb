require 'spec_helper'

module Cellect::Client
  describe Connection do
    let(:connection){ Cellect::Client.connection }
    
    before(:each) do
      Cellect::Client.node_set.stub(:nodes).and_return 'a' => '1', 'b' => '2'
    end
    
    def should_send(action: action, url: url, to: to)
      HTTP.should_receive(:send).with action, "http://#{ to }/#{ url }", socket_class: Celluloid::IO::TCPSocket
    end
    
    def should_broadcast(action: action, url: url)
      [1, 2].each{ |i| should_send action: action, url: url, to: i }
    end
    
    it 'should reload projects' do
      should_broadcast action: :post, url: 'projects/random/reload'
      connection.reload_project 'random'
    end
    
    it 'should delete projects' do
      should_broadcast action: :delete, url: 'projects/random'
      connection.delete_project 'random'
    end
    
    it 'should add subjects' do
      should_broadcast action: :put, url: 'projects/random/add?subject_id=123'
      connection.add_subject 123, project_id: 'random'
    end
    
    it 'should add grouped subjects' do
      should_broadcast action: :put, url: 'projects/random/add?subject_id=123&group_id=321'
      connection.add_subject 123, project_id: 'random', group_id: 321
    end
    
    it 'should add prioritized grouped subjects' do
      should_broadcast action: :put, url: 'projects/random/add?subject_id=123&group_id=321&priority=0.123'
      connection.add_subject 123, project_id: 'random', group_id: 321, priority: 0.123
    end
    
    it 'should remove subjects' do
      should_broadcast action: :put, url: 'projects/random/remove?subject_id=123'
      connection.remove_subject 123, project_id: 'random'
    end
    
    it 'should remove grouped subjects' do
      should_broadcast action: :put, url: 'projects/random/remove?subject_id=123&group_id=321'
      connection.remove_subject 123, project_id: 'random', group_id: 321
    end
    
    it 'should load users' do
      should_send action: :post, url: 'projects/random/users/123/load', to: 1
      connection.load_user 123, host: '1', project_id: 'random'
    end
    
    it 'should add seen subjects' do
      should_send action: :put, url: 'projects/random/users/123/add_seen?subject_id=456', to: 1
      connection.add_seen 456, host: '1', user_id: 123, project_id: 'random'
    end
  end
end
