shared_examples_for 'workflow' do |name|
  it 'should add singleton instances to the registry' do
    expect(obj.class[obj.name]).to be_a_kind_of Cellect::Server::Workflow
    expect(obj.class[obj.name].object_id).to eq obj.class[obj.name].object_id
  end

  it 'should initialize empty' do
    expect(obj.name).to be_a String
    expect(obj.users).to be_a Hash

    if obj.grouped?
      expect(obj.subjects).to eq({})
    else
      set_klass = obj.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet
      expect(obj.subjects).to be_a set_klass
    end
  end

  it 'should provide a user lookup' do
    expect(obj.user(1)).to be_a Cellect::Server::User
    expect(obj.user(1).object_id).to eq obj.user(1).object_id
    expect(obj.users.keys).to include 1
  end

  describe '#load_data' do
    it 'should request data from the adapater' do
      expect(Cellect::Server.adapter)
        .to receive(:load_data_for)
        .with(obj.name)
        .and_return([])
      obj.load_data
    end

    it 'should add data to subjects' do
      expect { obj.load_data }.to change { obj.subjects.size }
    end

    it 'should not reload subjects when in ready state' do
      obj.state = :ready
      expect { obj.load_data }.not_to change { obj.subjects.size }
    end
  end

  describe '#reload_data' do
    let(:adapter) { Cellect::Server.adapter }

    context "able to reload" do
      before do
        obj.can_reload_at = Time.now - 1
        obj.state = :ready
      end

      it 'should request data from the adapater' do
        expect(adapter)
          .to receive(:load_data_for)
          .with(obj.name)
          .and_return([])
        obj.reload_data
      end

      it 'should add data to subjects' do
        expect { obj.reload_data }.to change { obj.subjects }
      end

      it 'should not reload subjects when state is in any kind of loading' do
        %i(reloading loading).each do |state|
          obj.state = state
          expect(adapter).not_to receive(:load_data_for)
          obj.reload_data
        end
      end
    end

    it 'should not allow reloading until after loading' do
      expect(adapter).not_to receive(:load_data_for)
      obj.reload_data
    end

    context "after initial data load" do
      before do
        obj.load_data
      end

      it 'should not allow reloading after first load' do
        expect(adapter).not_to receive(:load_data_for)
        obj.reload_data
      end

      context "when reload time gaurds has past" do
        it 'should allow reloading after timer has reset' do
          obj.can_reload_at = Time.now - 1
          expect(adapter).to receive(:load_data_for).and_call_original
          obj.reload_data
        end
      end
    end
  end
end
