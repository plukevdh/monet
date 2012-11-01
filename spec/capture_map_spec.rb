require 'spec_helper'
require 'monet/capture_map'

describe Monet::CaptureMap::PathHelper do
  context "base helper" do
    Given(:helper) { Monet::CaptureMap::PathHelper.new }
    Then { helper.paths.should == [] }
  end

  context "add items" do
    Given(:helper) { Monet::CaptureMap::PathHelper.new }
    When { helper.add('path') }
    Then { helper.paths.should == ['path'] }
  end

end


describe Monet::CaptureMap do
  context "no arguments" do
    Then { expect { Monet::CaptureMap.new }.to have_failed(ArgumentError) }
  end

  context "with name" do
    Given(:map) { Monet::CaptureMap.new("test") }
    Then { map.name.should == :test }
    And { map.paths.should == [] }
  end

  context "add paths" do
    Given(:map) {
      Monet::CaptureMap.new(:test) do |map|
        map.add 'home/'
        map.add 'test/new'
      end
    }

    Then { map.name.should == :test }
    And { map.paths.should == ['home', 'test/new'] }
  end
end