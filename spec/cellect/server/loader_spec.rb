require 'spec_helper'

module Cellect::Server
  describe Loader do
    SET_TYPES.each do |workflow_type|
      let(:workflow) { Workflow.new(workflow_type) }
      let(:loader) { Loader.new(workflow) }
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
            .to receive(:add)
            .exactly(fixture_count)
          loader.load_data
        end

        it "should mark the workflow as loaded" do
          expect { loader.load_data }.to change { workflow.state }.to(:ready)
        end
      end

      describe "#reload_data" do
        let(:subjects) { workflow.set_klass.new }

        it "should add data to the workflow subjects" do
          expect(subjects)
            .to receive(:add)
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
  end
end
