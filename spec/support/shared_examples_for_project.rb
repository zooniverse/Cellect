shared_examples_for 'project' do |name|
  let(:obj){ send name }
  
  it 'should add singleton instances to the registry' do
    obj.class[:foo].should be_a_kind_of Cellect::Project
    obj.class[:foo].object_id.should == obj.class[:foo].object_id
  end
  
  it 'should initialize empty' do
    project.name.should == 'test'
    project.users.should be_a Hash
    project.subjects.should be_a DiffSet::RandomSet
  end
  
  it 'should provide a user lookup' do
    project.user('foo').should be_a Cellect::User
    project.user('foo').object_id.should == project.user('foo').object_id
    project.users.keys.should include 'foo'
  end
end
