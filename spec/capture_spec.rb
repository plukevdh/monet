require 'spec_helper'
require 'monet/capture'

describe Monet::Capture do
  Given(:path) { './spec/tmp/output' }
  Given(:capture_agent) { Monet::Capture.new(base_path: path) }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return

    Dir.glob("#{path}/*.png").each do |file|
      File.delete(file)
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