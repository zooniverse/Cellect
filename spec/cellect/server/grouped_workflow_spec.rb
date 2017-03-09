require 'spec_helper'

module Cellect::Server
  describe GroupedWorkflow do
    SET_TYPES.collect{ |type| "grouped_#{ type }" }.each do |workflow_type|
      context workflow_type do
        let(:workflow){ GroupedWorkflow.new(workflow_type) }
        let(:user){ workflow.user 123 }
        let(:set_klass){ workflow.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet }

        it_behaves_like 'workflow', :workflow do
          let(:obj) { workflow }
        end

        describe "#group" do
          context "no group is pre-defined" do
            it "should be an empty set" do
              expect(workflow.subjects).to be_empty
            end

            it "should setup a group" do
              expect(workflow.group(1)).to be_instance_of(workflow.set_klass)
            end

            it "should setup a group if no group_id param" do
              expect(workflow.group).to be_instance_of(workflow.set_klass)
            end
          end

          context "with a pre-defined group" do
            let(:set) { workflow.set_klass.new }
            before do
              workflow.subjects = { 1 => set }
            end

            it 'should retrieve a pre-defined group' do
              expect(workflow.group(1)).to eq(set)
            end

            it 'should randomly select if no group param' do
              expect(workflow.group).to eq(set)
            end
          end
        end

        describe "#unseen_for" do
          it 'should not fail if a group is not loaded' do
            workflow.subjects = { }
            expect { workflow.unseen_for 123, limit: 3 }.not_to raise_error
          end

          it 'should provide unseen from a random group for users' do
            workflow.subjects = { }
            workflow.groups[1] = set_klass.new
            expect(workflow.groups[1]).to receive(:subtract).with user.seen, 3
            workflow.unseen_for 123, limit: 3
          end

          it 'should provide unseen from a specific group for users' do
            3.times{ |i| workflow.groups[i] = set_klass.new }
            expect(workflow.group(1)).to receive(:subtract).with user.seen, 3
            workflow.unseen_for 123, group_id: 1, limit: 3
          end
        end

        describe "#sample" do
          it 'should not fail if a group is not loaded' do
            workflow.subjects = { }
            expect { workflow.sample limit: 3 }.not_to raise_error
          end

          it 'should sample subjects from a random group without a user' do
            workflow.subjects = { }
            workflow.groups[1] = set_klass.new
            expect(workflow.group(1)).to receive(:sample).with 3
            workflow.sample limit: 3
          end

          it 'should sample subjects from a specific group without a user' do
            3.times{ |i| workflow.groups[i] = set_klass.new }
            expect(workflow.group(1)).to receive(:sample).with 3
            workflow.sample group_id: 1, limit: 3
          end

          it 'should sample subjects from a random group for a user' do
            workflow.subjects = { }
            workflow.groups[1] = set_klass.new
            expect(workflow.groups[1]).to receive(:subtract).with user.seen, 3
            workflow.sample user_id: 123, limit: 3
          end

          it 'should sample subjects from a specific group for a user' do
            3.times{ |i| workflow.groups[i] = set_klass.new }
            expect(workflow.group(1)).to receive(:subtract).with user.seen, 3
            workflow.sample user_id: 123, group_id: 1, limit: 3
          end
        end

        describe "#add" do
          let(:opts) do
            opts = { subject_id: 123, group_id: 1 }
            opts[:priority] = 456 if workflow.prioritized?
            opts
          end

          it 'should add a data to a new group if a group is not loaded' do
            workflow.subjects = { }
            workflow.add opts
            group_data = workflow.subjects[1]
            expect(group_data.to_a).to_not eq(opts[:subject_id])
          end

          it 'should add subjects' do
            workflow.groups[1] = set_klass.new

            if workflow.prioritized?
              expect(workflow.groups[1]).to receive(:add).with 123, 456
              workflow.add opts
            else
              expect(workflow.groups[1]).to receive(:add).with 123
              workflow.add opts
            end
          end
        end

        describe "#remove" do
          it 'should not fail if a group is not loaded' do
            workflow.subjects = { }
            expect { workflow.remove subject_id: 123, group_id: 1 }.not_to raise_error
          end

          it 'should remove subjects' do
            workflow.groups[1] = set_klass.new
            expect(workflow.groups[1]).to receive(:remove).with 123
            workflow.remove subject_id: 123, group_id: 1
          end
        end

        it 'should be grouped' do
          expect(workflow).to be_grouped
        end
      end
    end
  end
end
