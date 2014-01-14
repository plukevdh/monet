require 'spec_helper'

require 'chunky_png'
require 'monet'
require 'monet/capture'

describe Monet::Capture do
  Given(:path) { File.expand_path './spec/tmp/output' }
  Given(:url) { "https://google.com" }
  Given(:capture_agent) { create_capture(config) }

  def create_capture(config)
    Monet::Capture.new config
  end

  after(:all) do
    Dir.glob("#{path}/**/*.png").each do |file|
      File.delete(file)
    end
  end

  context "simple config" do
    Given(:config) do
      Monet::Config.config do |c|
        c.base_url = "https://google.com"
        c.capture_dir = File.join(path, "captures")
        c.thumbnail_dir = File.join(path, "thumbnails")
      end
    end

    context "can capture a path" do
      When { capture_agent.capture(url, "#{path}/google.com/google.com-280.png") }
      Then { File.exist?("#{path}/google.com/google.com-280.png").should be_true }
    end

    context "can capture an image object" do
      Given(:img) { Monet::Image.new(File.join(path, "google.com", "google.com|chrome-1024.png")) }
      When { capture_agent.capture("#{url}/chrome", img) }
      Then { File.exist?("#{path}/google.com/google.com|chrome-1024.png").should be_true }
    end

    context "tracks error pages" do
      Given(:img) { Monet::Image.new(File.join(path, "google.com", "notapath-800.png")) }
      When(:captured) { capture_agent.capture("#{url}/notapath", img) }
      Then { captured.should be_a(Monet::ErrorImage) }
      And { File.exist?(captured.path).should be_true }
      And { captured.error.should eq(404) }
    end
  end

  context "converts name properly" do
    Given(:config) { Monet::Config.config {|c|
      c.base_url = url
      c.capture_dir = path
      c.dimensions = [900]
      c.map = ["/"]
    }}
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/google.com/google.com-900.png").should be_true }
  end

  context "captures all dimensions requested" do
    Given(:config) { Monet::Config.config {|c|
      c.base_url = url
      c.capture_dir = path
      c.dimensions =  [900, 1400]
      c.map = ["/"]
    }}
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/google.com/google.com-900.png").should be_true }
    Then { File.exist?("#{path}/google.com/google.com-1400.png").should be_true }
  end

  context "captures defualt size as 1024" do
    Given(:config) { Monet::Config.config {|c|
      c.base_url = "https://www.facebook.com"
      c.capture_dir = path
      c.map = ["/"]
    }}
    When { capture_agent.capture_all }
    Then { File.exist?("#{path}/www.facebook.com/www.facebook.com-1024.png").should be_true }
  end

  context "capturing" do
    Given(:thumb_path) { "#{path}/thumbnails/www.spider.io/www.spider.io-1024.png" }
    Given(:config) { Monet::Config.config do |c|
        c.capture_dir = path
        c.thumbnail_dir = File.join(path, "thumbnails")
        c.base_url = "https://www.spider.io"
        c.thumbnail = true
        c.map = ["/"]
      end
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