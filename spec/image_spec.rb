require 'spec_helper'
require 'monet'
require 'monet/image'

describe Monet::Image do
  Given(:img) { Monet::Image.new("./spec/fixtures/baselines/lance.com/lance.com-1024.png") }

  context "knows width" do
    Then { img.width.should == 1024 }
  end

  context "can create an image" do
    Then { img.to_image.should be_a(ChunkyPNG::Image) }
  end

  context "generates files" do
    Given(:img) { Monet::Image.new("./spec/tmp/test.png") }

    after(:all) do
      tmp = Dir.glob("./spec/tmp/**/*-thumb.png")
      tmp.each {|f| File.delete f }
    end

    context "can thumbnail self without a path" do
      When(:path) { img.thumbnail! }
      Then { path.should_not have_failed }
      And { File.exists?(path).should be_true }
    end

    context "can thumbnail self with a path" do
      When(:path) { img.thumbnail!("./spec/tmp/output/thumbnails") }
      Then { path.should_not have_failed }
      And { File.exists?(path).should be_true }
    end
  end
end