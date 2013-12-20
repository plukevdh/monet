require 'spec_helper'
require 'monet/config'
require 'monet/image'

describe Monet::Image do
  Given(:config) { Monet::Config.new(compare_type: "ColorBlend", capture_dir: "./spec/fixtures/captures", baseline_dir: "./spec/fixtures/baselines", thumbnail_dir: "./spec/fixtures/thumbnails", base_url: "http://lance.com") }

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
  end

  context "raises exception when no diff found" do
    Given(:img) { Monet::Image.new("./spec/fixtures/baselines/lance.com/lance.com|aboutus-1024.png", config) }
    When(:diff) { img.diff }
    Then { diff.should have_failed(Monet::Image::NoDiffFound) }
  end
end