require 'spec_helper'
require 'monet/compare'
require 'monet/errors'

describe Monet::Compare do
  Given(:image_base) { './spec/fixtures/base.png' }
  Given(:image_same) { './spec/fixtures/same.png' }
  Given(:image_diff) { './spec/fixtures/diff.png' }
  Given(:image_diff_size) { './spec/fixtures/diff_size.png' }
  Given(:diff_name)  { './spec/fixtures/base-diff.png' }

  context "default compare" do
    Given(:compare) { Monet::Compare.new }

    context "identical image" do
      When(:result) { compare.compare(image_base, image_same) }
      Then { result.should_not be_modified }
      And { File.exist?(diff_name).should be_false }
    end

    context "modified image" do
      after do
        File.delete(diff_name)
      end

      When(:result) { compare.compare(image_base, image_diff) }
      Then { result.should be_modified }
      And { File.exist?(diff_name).should be_true }
    end

    context "rejects mismatched dimensions" do
      When(:result) { compare.compare(image_base, image_diff_size) }
      Then { result.should have_failed(Monet::Errors::DifferentDimensions, /different dimensions/) }
    end
  end

  context "grayscale compare" do
    after do
      File.delete(diff_name)
    end

    Given(:compare) { Monet::Compare.new(Monet::Grayscale) }

    When(:result) { compare.compare(image_base, image_diff) }

    Then { result.should be_modified }
    And { File.exist?(diff_name).should be_true }
    And { result.pixels_changed.should eq(2387) }
    And { result.percentage_changed.should eq(0.55) }
  end
end