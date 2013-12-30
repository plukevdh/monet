require 'spec_helper'
require 'monet/config'
require 'monet/image'

describe Monet::Image do
  Given(:config) { Monet::Config.new(compare_type: "ColorBlend", capture_dir: "./spec/fixtures/captures", baseline_dir: "./spec/fixtures/baselines", thumbnail_dir: "./spec/fixtures/thumbnails", base_url: "http://lance.com", map: ["/test1", "/test2"], dimensions: [1234, 5678]) }

  context "with a flagged image" do
    When(:img) { Monet::Image.new("./spec/fixtures/baselines/lance.com/lance.com-1024.png", config) }

    context "is this a baseline?" do
      Then { img.should be_baseline }
    end

    context "is this image flagged?" do
      Then { img.should be_flagged }
    end

    context "knows how to get the thumbnail for itself" do
      Then { img.thumbnail.should == File.expand_path("./spec/fixtures/thumbnails/lance.com/lance.com-1024.png") }
    end

    context "knows how to get the diff for itself" do
      Then { img.diff.should == File.expand_path("./spec/fixtures/baselines/lance.com/lance.com-1024-diff.png") }
    end

    context "knows how to get the captured image for itself" do
      Then { img.capture.should == File.expand_path("./spec/fixtures/captures/lance.com/lance.com-1024.png") }
    end

    context "knows width" do
      Then { img.width.should == 1024 }
    end
  end

  context "can produce a set of image specs from the config" do
    When(:images) { Monet::Image.from_config(config) }
    Then { images.count.should == 4 }
    And { images.first.name.should == "lance.com|test1-1234.png" }
  end

  context "can create from a url" do
    When(:img) { Monet::Image.from_url("http://lance.com/aboutus", config, "1024") }
    Then { img.baseline.should == File.expand_path("./spec/fixtures/baselines/lance.com/lance.com|aboutus-1024.png") }
    And { img.url.should == "http://lance.com/aboutus" }
  end

  context "can get url from base path" do
    When(:img) { Monet::Image.new("./spec/fixtures/baselines/lance.com/lance.com-1024.png", config) }
    Then { img.url.should == "http://lance.com/" }
  end

  context "raises exception when no diff found" do
    Given(:img) { Monet::Image.new("./spec/fixtures/baselines/lance.com/lance.com|aboutus-1024.png", config) }
    When(:diff) { img.diff }
    Then { diff.should have_failed(Monet::Image::NoDiffFound) }
  end

  shared_examples "url mapping" do |type|
    Given(:public_path) { File.join(File.dirname(__FILE__), "fixtures") }

    context "can get an image url for an image" do
      Given(:img) { Monet::Image.new("./spec/fixtures/#{type}/lance.com/lance.com|aboutus-1024.png", config) }
      When(:url) { img.send "#{type}_url", public_path }
      Then { url.should == "/#{type}s/lance.com/lance.com|aboutus-1024.png" }
    end
  end

  context "baseline" do
    it_should_behave_like "url mapping", "baseline"
  end

  context "baseline" do
    it_should_behave_like "url mapping", "capture"
  end

  context "baseline" do
    it_should_behave_like "url mapping", "thumbnail"
  end
end