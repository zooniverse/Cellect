shared_examples_for 'loader' do |name|
  let(:fixtures) do
    Cellect::Server
      .adapter
      .fixtures
      .fetch(workflow.name, { })
      .fetch('entries', [])
  end
  let(:fixture_count) { fixtures.count }

  describe "#load_data" do
    it "should use the server adapter to load data" do
      expect(Cellect::Server.adapter)
        .to receive(:load_data_for)
        .with(workflow.name)
        .and_call_original
      loader.load_data
    end

    it "should mark the workflow as loaded" do
      expect { loader.load_data }.to change { workflow.state }.to(:ready)
    end
  end

  describe "#reload_data" do
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
