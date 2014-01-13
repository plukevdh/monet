require 'spec_helper'
require 'monet/capture_map'

describe Monet::CaptureMap::PathCollection do
  context "base helper" do
    Given(:helper) { Monet::CaptureMap::PathCollection.new("http://google.com") }
    Then { helper.paths.should == [] }
  end

  context "add items" do
    Given(:helper) { Monet::CaptureMap::PathCollection.new("http://google.com") }
    When { helper.add('path') }
    Then { helper.paths.should == ['path'] }
  end
end

describe Monet::CaptureMap::PathSpider do
  Given(:spider) { Monet::CaptureMap::PathSpider.new("http://spider.io/") }

  context "ignores" do
    When(:ignores) { spider.ignores }
    Then { ignores.all? {|x| x.is_a? Regexp}.should be_true }
  end
end

describe Monet::CaptureMap do
  context "no arguments" do
    When(:result) { Monet::CaptureMap.new }
    Then { result.should have_failed(ArgumentError) }
  end

  context "requires full url" do
    When(:result) { Monet::CaptureMap.new("google.com") }
    Then { result.should have_failed(Monet::InvalidURL, /google.com is not a valid url/) }
  end

  context "requires valid url" do
    When(:result) { Monet::CaptureMap.new("google") }
    Then { result.should have_failed(Monet::InvalidURL, /google is not a valid url/) }
  end

  context "with name" do
    Given(:map) { Monet::CaptureMap.new("http://google.com") }
    Then { map.root_url.to_s.should == "http://google.com" }
    And { map.paths.should == [] }
  end

  context "with paths" do
    Given(:map) {
      Monet::CaptureMap.new("http://google.com") do |map|
        map.add 'home/'
        map.add 'test/new'
      end
    }

    context "add paths" do
      Then { map.root_url.to_s.should == "http://google.com" }
      And { map.paths.should == ['home', 'test/new'] }
    end
  end

  context "spider mapper", vcr: { cassette_name: "spider-map", record: :new_episodes } do
    Given(:map) { Monet::CaptureMap.new("http://staging.lance.com", :spider) }
    When(:paths) { map.paths }
    Then { paths.size.should == 67 }
    And { paths.first.end_with?("/").should be false }
    And { paths.first.start_with?("http://").should be_false }
    And { paths.any? {|p| p.end_with? "css" }.should be_false }
  end
end

