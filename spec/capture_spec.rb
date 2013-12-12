require 'spec_helper'
require 'monet/capture'

describe Monet::Capture do
  Given(:path) { File.expand_path './spec/tmp/output' }
  Given(:capture_agent) { Monet::Capture.new(capture_dir: path) }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return

    Dir.glob("#{path}/*.png").each do |file|
      File.delete(file)
    end
  end

  context "can pass config" do
    context "as a hash" do
      Given(:capture_agent) { Monet::Capture.new(capture_dir: path) }
      When(:config) { capture_agent.instance_variable_get :@config }
      Then { config.should be_a(Monet::Config) }
      Then { config.capture_dir.should == path }
    end

    context "as a Monet::Config" do
      Given(:config) { Monet::Config.new(capture_dir: path) }
      Given(:capture_agent) { Monet::Capture.new(config) }
      When(:final) { capture_agent.instance_variable_get :@config }
      Then { final.should be_a(Monet::Config) }
      Then { final.capture_dir.should == path }
    end
  end

  context "converts name properly" do
    When { capture_agent.capture('https://google.com') }
    Then { File.exist?("#{path}/google_com-#{Time.now.to_i}.png").should be_true }
  end

  context "prepends default protocol if missing" do
    When { capture_agent.capture('www.facebook.com') }
    Then { File.exist?("#{path}/www_facebook_com-#{Time.now.to_i}.png").should be_true }
  end

end