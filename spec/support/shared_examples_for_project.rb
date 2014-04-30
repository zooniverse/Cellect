shared_examples_for 'project' do |name|
  let(:obj){ send name }
  
  before(:each) do
    Cellect.adapter.load_project obj.name
  end
  
  it 'should add singleton instances to the registry' do
    obj.class[:foo].should be_a_kind_of Cellect::Project
    obj.class[:foo].object_id.should == obj.class[:foo].object_id
  end
  
  it 'should initialize empty' do
    obj.name.should be_a String
    obj.users.should be_a Hash
    
    set_klass = obj.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet
    obj.subjects.should be_a set_klass
  end
  
  it 'should provide a user lookup' do
    obj.user(1).should be_a Cellect::User
    obj.user(1).object_id.should == obj.user(1).object_id
    obj.users.keys.should include 1
  end
end
