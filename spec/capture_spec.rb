require 'spec_helper'

require 'chunky_png'
require 'monet/capture'

describe Monet::Capture do
  Given(:path) { File.expand_path './spec/tmp/output' }
  Given(:url) { "http://google.com" }
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

  context "converts name properly" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url, dimensions: [900]) }
    When { capture_agent.capture("/") }
    Then { File.exist?("#{path}/google.com/google.com|-900.png").should be_true }
  end

  context "captures all dimensions requested" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: url, dimensions: [900, 1400]) }
    When { capture_agent.capture("/") }
    Then { File.exist?("#{path}/google.com/google.com|-900.png").should be_true }
    Then { File.exist?("#{path}/google.com/google.com|-1400.png").should be_true }
  end

  context "prepends default protocol if missing" do
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path, base_url: "http://www.facebook.com") }
    When { capture_agent.capture('/') }
    Then { File.exist?("#{path}/www.facebook.com/www.facebook.com|-1024.png").should be_true }
  end

  context "captured" do
    Given(:thumb_path) { "#{path}/thumbnails/www.spider.io/www.spider.io|-1024.png" }
    Given(:capture_agent) { Monet::Capture.new(capture_dir: path,
      thumbnail_dir: File.join(path, "thumbnails"),
      base_url: "http://www.spider.io",
      thumbnail: true)
    }
    When { capture_agent.capture('/') }

    context "can thumbnail an image" do
      Then { File.exist?("#{path}/www.spider.io/www.spider.io|-1024.png").should be_true }
      And { File.exist?(thumb_path).should be_true }
    end

    context "thumb is 200x200" do
      When(:thumb) { ChunkyPNG::Image.from_file(thumb_path) }
      Then { thumb.width.should == 200 }
      And { thumb.height.should == 200 }
    end
  end
end