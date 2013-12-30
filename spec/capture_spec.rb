require 'spec_helper'

require 'chunky_png'
require 'monet/capture'

describe Monet::Capture do
  Given(:path) { File.expand_path './spec/tmp/output' }
  Given(:url) { "https://google.com" }
  Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url) }

  after(:all) do
    Dir.glob("#{path}/**/*.png").each do |file|
      File.delete(file)
    end
  end

  context "can pass config" do
    context "as a hash" do
      Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url) }
      When(:config) { capture_agent.instance_variable_get :@config }
      Then { config.should be_a(Monet::Config) }
      Then { config.capture_dir.should == path }
    end

    context "as a Monet::Config" do
      Given(:config) { Monet::Config.new(capture_dir: path, base_url: url) }
      Given(:capture_agent) { Monet::Capture.new(config) }
      When(:final) { capture_agent.instance_variable_get :@config }
      Then { final.should be_a(Monet::Config) }
      Then { final.capture_dir.should == path }
    end
  end

  context "requires width for path" do
    When(:result) { capture_agent.capture('/') }
    Then { result.should have_failed(ArgumentError, /Width is required/) }
  end

  context "can capture a path with a width" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url) }
    When { capture_agent.capture("/", 280) }
    Then { File.exist?("#{path}/google.com/google.com-280.png").should be_true }
  end

  context "converts name properly" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url, dimensions: [900], map: ["/"]) }
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/google.com/google.com-900.png").should be_true }
  end

  context "captures all dimensions requested" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url, dimensions: [900, 1400], map: ["/"]) }
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/google.com/google.com-900.png").should be_true }
    Then { File.exist?("#{path}/google.com/google.com-1400.png").should be_true }
  end

  context "captures defualt size as 1024" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: "https://www.facebook.com", map: ["/"]) }
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/www.facebook.com/www.facebook.com-1024.png").should be_true }
  end

  context "can capture an image object" do
    Given(:config) { capture_agent.instance_variable_get(:@config) }
    Given(:img) { Monet::Image.new(File.join(path, "google.com", "google.com|chrome-1024.png"), config) }
    When { capture_agent.capture(img) }
    Then { File.exist?("#{path}/google.com/google.com|chrome-1024.png").should be_true }
  end

  context "capturing" do
    Given(:thumb_path) { "#{path}/thumbnails/www.spider.io/www.spider.io-1024.png" }
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path,
      thumbnail_dir: File.join(path, "thumbnails"),
      base_url: "https://www.spider.io",
      thumbnail: true,
      map: ["/"])
    }
    When { capture_agent.capture_all }

    context "can thumbnail an image" do
      Then { File.exist?("#{path}/www.spider.io/www.spider.io-1024.png").should be_true }
      And { File.exist?(thumb_path).should be_true }
    end

    context "thumbnail sizes to 200x200" do
      When(:thumb) { ChunkyPNG::Image.from_file(thumb_path) }
      Then { thumb.width.should == 200 }
      And { thumb.height.should == 200 }
    end
  end
end