shared_examples_for 'loader' do |name|
  let(:fixture_count) do
    Cellect::Server
      .adapter
      .fixtures
      .fetch(workflow.name, { })
      .fetch('entries', [])
      .count
  end

  describe "#load_data" do
    it "should use the server adapter to load data" do
      expect(Cellect::Server.adapter)
        .to receive(:load_data_for)
        .with(workflow.name)
        .and_call_original
      loader.load_data
    end

    it "should add data to the workflow subjects" do
      expect(workflow.subjects)
        .to receive(load_method)
        .exactly(fixture_count)
      loader.load_data
    end

    it "should mark the workflow as loaded" do
      expect { loader.load_data }.to change { workflow.state }.to(:ready)
    end
  end

  describe "#reload_data" do
    it "should add data to the workflow subjects" do
      expect(subjects)
        .to receive(load_method)
        .exactly(fixture_count)
      loader.reload_data(subjects)
    end

    it "should replace the existing subjects with the reloaded set" do
      expect {
        loader.reload_data(subjects)
      }.to change {
        workflow.subjects
      }.to(subjects)
    end

    it "should mark the workflow as ready" do
      expect {
        loader.reload_data(subjects)
      }.to change {
        workflow.state
      }.to(:ready)
    end
  end
end
