shared_examples_for 'workflow' do |name|
  it 'should add singleton instances to the registry' do
    expect(obj.class[obj.name]).to be_a_kind_of Cellect::Server::Workflow
    expect(obj.class[obj.name].object_id).to eq obj.class[obj.name].object_id
  end

  it 'should initialize empty' do
    expect(obj.name).to be_a String
    expect(obj.users).to be_a Hash

    set_klass = obj.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet
    expect(obj.subjects).to be_a set_klass
  end

  it 'should provide a user lookup' do
    expect(obj.user(1)).to be_a Cellect::Server::User
    expect(obj.user(1).object_id).to eq obj.user(1).object_id
    expect(obj.users.keys).to include 1
  end
end
