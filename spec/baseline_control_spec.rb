require 'spec_helper'
require 'monet/baseline_control'

describe Monet::BaselineControl do
  Given(:control) do
    config = flexmock("Config", capture_dir: "./spec/fixtures", baseline_dir: "./baseline", base_url: "http://google.com")
    flexmock Monet::BaselineControl.new(config)
  end

  context "makes a capture baseline if no baseline exists" do
    Given(:diff) { Monet::BaselessImage.new("./fixtures/fake.png") }
    Given { control.should_receive(:baseline).with(diff).and_return("./baseline/fake.png") }

    When(:result) { control.compare(diff) }

    Then { control.should have_received(:baseline).with(diff) }
    And { result.should eq("./baseline/fake.png") }
  end

  context "discards captures that match baseline" do
    Given(:diff) { flexmock(:on, Monet::Changeset, modified?: false, path: "./fixtures/fake.png") }
    Given { control.should_receive(:discard).with("./fixtures/fake.png") }

    When(:result) { control.compare(diff) }

    Then { control.should have_received(:discard).with("./fixtures/fake.png") }
  end

  context "flags changed capture as different" do
    Given(:diff) { flexmock(:on, Monet::Changeset, modified?: true, path: "./fixtures/fake.png") }

    When(:diffs) { control.compare(diff) }

    Then { diffs.length.should == 1 }
    And { diffs.should == ["./fixtures/fake.png"] }
  end

  context "replaces baseline if requested" do
    Given(:diff) { flexmock(:on, Monet::Changeset, modified?: true, path: "./fixtures/fake.png") }
    Given { control.should_receive(:baseline).with(diff).and_return("./baseline/fake.png") }

    When(:result) { control.baseline(diff) }

    Then { control.should have_received(:baseline).with(diff) }
    And { result.should eq("./baseline/fake.png") }
  end
end