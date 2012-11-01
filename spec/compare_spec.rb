require 'spec_helper'
require 'monet/compare'

describe Monet::Compare do
  Given(:compare) { Monet::Compare.new }
  Given(:image_base) { './spec/fixtures/base.png' }
  Given(:image_same) { './spec/fixtures/same.png' }
  Given(:image_diff) { './spec/fixtures/diff.png' }
  Given(:diff_name)  { './spec/fixtures/base-diff.png' }

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

end